import Foundation
import Observation

// swiftlint:disable file_length

@MainActor
@Observable
final class MicrophoneStatusModel {
    private(set) var status: MicrophoneStatus = .stopped
    private(set) var isMonitoring = false
    private(set) var inputLevel = 0.0
    private(set) var hotKeyRegistrationError: String?
    private(set) var walkieTalkieHotKeyRegistrationError: String?
    private(set) var isWalkieTalkieEnabled = false

    var hotKey: HotKeyConfiguration {
        didSet {
            guard hotKey != oldValue else { return }
            saveHotKey()
            let didRegister = registerHotKey()
            analytics.track(.hotKeyChanged(success: didRegister))
        }
    }

    var walkieTalkieHotKey: HotKeyConfiguration {
        didSet {
            guard walkieTalkieHotKey != oldValue else { return }
            saveWalkieTalkieHotKey()
            let didRegister = registerWalkieTalkieHotKey()
            analytics.track(.walkieTalkieHotKeyChanged(success: didRegister))
            if !didRegister, isWalkieTalkieEnabled {
                setWalkieTalkieEnabled(false)
            }
        }
    }

    var isMuted: Bool {
        switch status {
        case .muted:
            true
        case .active, .stopped, .unavailable:
            false
        }
    }

    var canAdjustInputLevel: Bool {
        switch status {
        case .active, .muted:
            true
        case .stopped, .unavailable:
            false
        }
    }

    @ObservationIgnored private let microphone: any MicrophoneVolumeControlling
    @ObservationIgnored private let hotKeyManager: any HotKeyManaging
    @ObservationIgnored private let walkieTalkieHotKeyManager: any HotKeyManaging
    @ObservationIgnored private let analytics: any AnalyticsTracking
    @ObservationIgnored private var pollingTimer: Timer?
    @ObservationIgnored private var lastNonzeroVolume: Float32
    @ObservationIgnored private var currentInputDeviceID: UInt32?
    @ObservationIgnored private var lastTrackedErrorSignature: String?
    @ObservationIgnored private var desiredMuteState: MicrophoneMuteState = .indeterminate
    @ObservationIgnored private var isWalkieTalkiePressed = false
    @ObservationIgnored private var muteStateBeforeWalkieTalkie: MicrophoneMuteState = .indeterminate

    private static let hotKeyDefaultsKey = "muteHotKey"
    private static let walkieTalkieHotKeyDefaultsKey = "walkieTalkieHotKey"
    private static let walkieTalkieEnabledDefaultsKey = "walkieTalkieEnabled"
    private static let lastVolumeDefaultsKey = "lastNonzeroInputVolume"

    init(
        microphone: any MicrophoneVolumeControlling = CoreAudioMicrophone(),
        hotKeyManager: any HotKeyManaging = HotKeyManager(),
        walkieTalkieHotKeyManager: any HotKeyManaging = HotKeyManager(id: 2),
        analytics: any AnalyticsTracking = NoopAnalytics()
    ) {
        self.microphone = microphone
        self.hotKeyManager = hotKeyManager
        self.walkieTalkieHotKeyManager = walkieTalkieHotKeyManager
        self.analytics = analytics

        let savedHotKey = UserDefaults.standard.data(forKey: Self.hotKeyDefaultsKey).flatMap {
            try? JSONDecoder().decode(HotKeyConfiguration.self, from: $0)
        }
        if let savedHotKey, savedHotKey.modifierCount >= 2 {
            hotKey = savedHotKey
        } else {
            hotKey = .defaultValue
        }

        let savedWalkieTalkieHotKey = UserDefaults.standard
            .data(forKey: Self.walkieTalkieHotKeyDefaultsKey)
            .flatMap { try? JSONDecoder().decode(HotKeyConfiguration.self, from: $0) }
        if let savedWalkieTalkieHotKey, savedWalkieTalkieHotKey.modifierCount >= 2 {
            walkieTalkieHotKey = savedWalkieTalkieHotKey
        } else {
            walkieTalkieHotKey = .walkieTalkieDefaultValue
        }

        let savedVolume = UserDefaults.standard.double(forKey: Self.lastVolumeDefaultsKey)
        lastNonzeroVolume = savedVolume > 0 ? Float32(savedVolume) : 0.5
        inputLevel = savedVolume > 0 ? savedVolume : Double(lastNonzeroVolume)

        self.hotKeyManager.onPressed = { [weak self] in
            self?.toggleMute(source: .hotKey)
        }
        self.walkieTalkieHotKeyManager.onPressed = { [weak self] in
            self?.beginWalkieTalkieTransmission()
        }
        self.walkieTalkieHotKeyManager.onReleased = { [weak self] in
            self?.endWalkieTalkieTransmission()
        }

        _ = registerHotKey()
        _ = registerWalkieTalkieHotKey()
        startMonitoring(shouldTrack: false)

        if UserDefaults.standard.bool(forKey: Self.walkieTalkieEnabledDefaultsKey) {
            setWalkieTalkieEnabled(true, shouldTrack: false)
        }
    }

    func toggleMonitoring() {
        if isMonitoring {
            stopMonitoring()
        } else {
            startMonitoring()
        }
    }

    func startMonitoring() {
        startMonitoring(shouldTrack: true)
    }

    func stopMonitoring() {
        guard isMonitoring else { return }
        pollingTimer?.invalidate()
        pollingTimer = nil
        isMonitoring = false
        status = .stopped
        analytics.track(.monitoringChanged(enabled: false))
    }

    func setInputLevel(_ level: Double) {
        guard canAdjustInputLevel else { return }

        do {
            let deviceID = try microphone.defaultInputDeviceID()
            let clampedLevel = min(max(level, 0), 1)
            try microphone.setInputVolume(Float32(clampedLevel), for: deviceID)
            if clampedLevel > 0 {
                lastNonzeroVolume = Float32(clampedLevel)
                UserDefaults.standard.set(clampedLevel, forKey: Self.lastVolumeDefaultsKey)
            }

            let shouldMute = isWalkieTalkieEnabled
                ? !isWalkieTalkiePressed
                : clampedLevel == 0
            if try microphone.isMuted(for: deviceID) != shouldMute {
                try microphone.setMuted(shouldMute, for: deviceID)
            }
            currentInputDeviceID = deviceID
            desiredMuteState = shouldMute ? .muted : .active
            refreshStatus()
        } catch {
            status = .unavailable(error.localizedDescription)
            trackMicrophoneError(error, operation: .inputLevel)
        }
    }

    func trackInputLevelCommit() {
        let bucket = Int((inputLevel * 4).rounded()) * 25
        analytics.track(.inputLevelChanged(percentBucket: bucket))
    }

    func toggleMute(source: AnalyticsEvent.MuteSource = .button) {
        guard !isWalkieTalkieEnabled else { return }

        do {
            let deviceID = try microphone.defaultInputDeviceID()
            let targetMuteState = try !intendedMuteState(for: deviceID)
            try setMicrophoneMuted(targetMuteState, for: deviceID)
            lastTrackedErrorSignature = nil
            analytics.track(.muteChanged(isMuted: targetMuteState, source: source))

            if isMonitoring {
                refreshStatus()
            }
        } catch {
            if isMonitoring {
                status = .unavailable(error.localizedDescription)
            }
            trackMicrophoneError(error, operation: .mute)
        }
    }

    func retryMonitoring() {
        if isMonitoring {
            refreshStatus()
        } else {
            startMonitoring()
        }
    }

    func restoreDefaultHotKey() {
        hotKey = .defaultValue
    }

    func restoreDefaultWalkieTalkieHotKey() {
        walkieTalkieHotKey = .walkieTalkieDefaultValue
    }

    func setWalkieTalkieEnabled(_ isEnabled: Bool) {
        setWalkieTalkieEnabled(isEnabled, shouldTrack: true)
    }

    private func setWalkieTalkieEnabled(_ isEnabled: Bool, shouldTrack: Bool) {
        guard isEnabled != isWalkieTalkieEnabled else { return }
        guard !isEnabled || walkieTalkieHotKeyRegistrationError == nil else {
            UserDefaults.standard.set(false, forKey: Self.walkieTalkieEnabledDefaultsKey)
            return
        }

        if isEnabled {
            do {
                let deviceID = try microphone.defaultInputDeviceID()
                let wasMuted = try microphone.isMuted(for: deviceID)
                muteStateBeforeWalkieTalkie = wasMuted ? .muted : .active
                try setMicrophoneMuted(true, for: deviceID)
                isWalkieTalkieEnabled = true
                refreshStatus()
            } catch {
                muteStateBeforeWalkieTalkie = .indeterminate
                UserDefaults.standard.set(false, forKey: Self.walkieTalkieEnabledDefaultsKey)
                handleWalkieTalkieError(error)
                return
            }
        } else {
            isWalkieTalkieEnabled = false
            isWalkieTalkiePressed = false
            restoreMuteStateAfterWalkieTalkie()
        }

        UserDefaults.standard.set(isEnabled, forKey: Self.walkieTalkieEnabledDefaultsKey)
        if shouldTrack {
            analytics.track(.walkieTalkieChanged(enabled: isEnabled))
        }
    }

    private func beginWalkieTalkieTransmission() {
        guard isWalkieTalkieEnabled, !isWalkieTalkiePressed else { return }
        isWalkieTalkiePressed = true
        setWalkieTalkieMuted(false)
    }

    private func endWalkieTalkieTransmission() {
        guard isWalkieTalkieEnabled else { return }
        isWalkieTalkiePressed = false
        setWalkieTalkieMuted(true)
    }

    private func setWalkieTalkieMuted(_ muted: Bool) {
        do {
            let deviceID = try microphone.defaultInputDeviceID()
            try setMicrophoneMuted(muted, for: deviceID)
            lastTrackedErrorSignature = nil
            refreshStatus()
        } catch {
            handleWalkieTalkieError(error)
        }
    }

    private func restoreMuteStateAfterWalkieTalkie() {
        let shouldMute: Bool
        switch muteStateBeforeWalkieTalkie {
        case .active:
            shouldMute = false
        case .muted:
            shouldMute = true
        case .indeterminate:
            return
        }
        muteStateBeforeWalkieTalkie = .indeterminate

        do {
            let deviceID = try microphone.defaultInputDeviceID()
            try setMicrophoneMuted(shouldMute, for: deviceID)
            lastTrackedErrorSignature = nil
            refreshStatus()
        } catch {
            handleWalkieTalkieError(error)
        }
    }

    private func handleWalkieTalkieError(_ error: Error) {
        if isMonitoring {
            status = .unavailable(error.localizedDescription)
        }
        trackMicrophoneError(error, operation: .walkieTalkie)
    }

    private func refreshStatus() {
        guard isMonitoring else { return }

        do {
            let deviceID = try microphone.defaultInputDeviceID()
            let deviceChanged = currentInputDeviceID.map { $0 != deviceID } ?? false
            if deviceChanged {
                try applyDesiredMuteState(to: deviceID)
            }

            var muted = try microphone.isMuted(for: deviceID)
            if isWalkieTalkieEnabled {
                let shouldMute = !isWalkieTalkiePressed
                if muted != shouldMute {
                    try setMicrophoneMuted(shouldMute, for: deviceID)
                    muted = shouldMute
                }
            }

            let volume = try microphone.inputVolume(for: deviceID)
            currentInputDeviceID = deviceID
            desiredMuteState = muted ? .muted : .active
            inputLevel = Double(volume)
            if volume > 0 {
                lastNonzeroVolume = volume
                UserDefaults.standard.set(Double(volume), forKey: Self.lastVolumeDefaultsKey)
            }
            status = muted ? .muted : .active(volume)
            lastTrackedErrorSignature = nil
        } catch {
            status = .unavailable(error.localizedDescription)
            trackMicrophoneError(error, operation: .monitoring)
        }
    }

    private func startMonitoring(shouldTrack: Bool) {
        guard !isMonitoring else { return }
        isMonitoring = true
        lastTrackedErrorSignature = nil
        if shouldTrack {
            analytics.track(.monitoringChanged(enabled: true))
        }
        refreshStatus()

        let timer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshStatus()
            }
        }
        pollingTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func trackMicrophoneError(
        _ error: Error,
        operation: AnalyticsEvent.MicrophoneOperation
    ) {
        let category = (error as? MicrophoneError)?.analyticsCategory ?? "unknown"
        let signature = "\(operation.rawValue):\(category)"
        guard signature != lastTrackedErrorSignature else { return }

        lastTrackedErrorSignature = signature
        analytics.track(.microphoneError(operation: operation, category: category))
    }

    private func intendedMuteState(for deviceID: UInt32) throws -> Bool {
        switch desiredMuteState {
        case .active:
            false
        case .muted:
            true
        case .indeterminate:
            try microphone.isMuted(for: deviceID)
        }
    }

    private func applyDesiredMuteState(to deviceID: UInt32) throws {
        if isWalkieTalkieEnabled {
            try setMicrophoneMuted(!isWalkieTalkiePressed, for: deviceID)
            return
        }

        switch desiredMuteState {
        case .active:
            try setMicrophoneMuted(false, for: deviceID)
        case .muted:
            try setMicrophoneMuted(true, for: deviceID)
        case .indeterminate:
            break
        }
    }

    private func setMicrophoneMuted(_ muted: Bool, for deviceID: UInt32) throws {
        if !muted, try microphone.inputVolume(for: deviceID) == 0 {
            try microphone.setInputVolume(max(lastNonzeroVolume, 0.01), for: deviceID)
        }

        try microphone.setMuted(muted, for: deviceID)
        currentInputDeviceID = deviceID
        desiredMuteState = muted ? .muted : .active
    }

    private func saveHotKey() {
        guard let data = try? JSONEncoder().encode(hotKey) else { return }
        UserDefaults.standard.set(data, forKey: Self.hotKeyDefaultsKey)
    }

    private func saveWalkieTalkieHotKey() {
        guard let data = try? JSONEncoder().encode(walkieTalkieHotKey) else { return }
        UserDefaults.standard.set(data, forKey: Self.walkieTalkieHotKeyDefaultsKey)
    }

    private func registerHotKey() -> Bool {
        do {
            try hotKeyManager.register(hotKey)
            hotKeyRegistrationError = nil
            return true
        } catch {
            hotKeyRegistrationError = error.localizedDescription
            return false
        }
    }

    private func registerWalkieTalkieHotKey() -> Bool {
        do {
            try walkieTalkieHotKeyManager.register(walkieTalkieHotKey)
            walkieTalkieHotKeyRegistrationError = nil
            return true
        } catch {
            walkieTalkieHotKeyRegistrationError = error.localizedDescription
            return false
        }
    }
}
