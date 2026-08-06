import Foundation
import Observation

@MainActor
@Observable
final class MicrophoneStatusModel {
    private(set) var status: MicrophoneStatus = .stopped
    private(set) var isMonitoring = false
    private(set) var inputLevel = 0.0
    private(set) var hotKeyRegistrationError: String?

    var hotKey: HotKeyConfiguration {
        didSet {
            guard hotKey != oldValue else { return }
            saveHotKey()
            registerHotKey()
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
    @ObservationIgnored private var pollingTimer: Timer?
    @ObservationIgnored private var lastNonzeroVolume: Float32
    @ObservationIgnored private var currentInputDeviceID: UInt32?
    @ObservationIgnored private var desiredMuteState: MicrophoneMuteState = .indeterminate

    private static let hotKeyDefaultsKey = "muteHotKey"
    private static let lastVolumeDefaultsKey = "lastNonzeroInputVolume"

    init(
        microphone: any MicrophoneVolumeControlling = CoreAudioMicrophone(),
        hotKeyManager: any HotKeyManaging = HotKeyManager()
    ) {
        self.microphone = microphone
        self.hotKeyManager = hotKeyManager

        let savedHotKey = UserDefaults.standard.data(forKey: Self.hotKeyDefaultsKey).flatMap {
            try? JSONDecoder().decode(HotKeyConfiguration.self, from: $0)
        }
        if let savedHotKey, savedHotKey.modifierCount >= 2 {
            hotKey = savedHotKey
        } else {
            hotKey = .defaultValue
        }

        let savedVolume = UserDefaults.standard.double(forKey: Self.lastVolumeDefaultsKey)
        lastNonzeroVolume = savedVolume > 0 ? Float32(savedVolume) : 0.5
        inputLevel = savedVolume > 0 ? savedVolume : Double(lastNonzeroVolume)

        self.hotKeyManager.onPressed = { [weak self] in
            self?.toggleMute()
        }

        registerHotKey()
        startMonitoring()
    }

    func toggleMonitoring() {
        if isMonitoring {
            stopMonitoring()
        } else {
            startMonitoring()
        }
    }

    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        refreshStatus()

        let timer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshStatus()
            }
        }
        pollingTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func stopMonitoring() {
        pollingTimer?.invalidate()
        pollingTimer = nil
        isMonitoring = false
        status = .stopped
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

            let shouldMute = clampedLevel == 0
            if try microphone.isMuted(for: deviceID) != shouldMute {
                try microphone.setMuted(shouldMute, for: deviceID)
            }
            currentInputDeviceID = deviceID
            desiredMuteState = shouldMute ? .muted : .active
            refreshStatus()
        } catch {
            status = .unavailable(error.localizedDescription)
        }
    }

    func toggleMute() {
        do {
            let deviceID = try microphone.defaultInputDeviceID()
            let currentlyMuted = try intendedMuteState(for: deviceID)
            if currentlyMuted, try microphone.inputVolume(for: deviceID) == 0 {
                try microphone.setInputVolume(max(lastNonzeroVolume, 0.01), for: deviceID)
            }

            let targetMuteState = !currentlyMuted
            try microphone.setMuted(targetMuteState, for: deviceID)
            currentInputDeviceID = deviceID
            desiredMuteState = targetMuteState ? .muted : .active

            if isMonitoring {
                refreshStatus()
            }
        } catch {
            if isMonitoring {
                status = .unavailable(error.localizedDescription)
            }
        }
    }

    func restoreDefaultHotKey() {
        hotKey = .defaultValue
    }

    private func refreshStatus() {
        guard isMonitoring else { return }

        do {
            let deviceID = try microphone.defaultInputDeviceID()
            let deviceChanged = currentInputDeviceID.map { $0 != deviceID } ?? false
            if deviceChanged {
                try applyDesiredMuteState(to: deviceID)
            }

            let volume = try microphone.inputVolume(for: deviceID)
            let muted = try microphone.isMuted(for: deviceID)
            currentInputDeviceID = deviceID
            desiredMuteState = muted ? .muted : .active
            inputLevel = Double(volume)
            if volume > 0 {
                lastNonzeroVolume = volume
                UserDefaults.standard.set(Double(volume), forKey: Self.lastVolumeDefaultsKey)
            }
            status = muted ? .muted : .active(volume)
        } catch {
            status = .unavailable(error.localizedDescription)
        }
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
        switch desiredMuteState {
        case .active:
            try microphone.setMuted(false, for: deviceID)
        case .muted:
            try microphone.setMuted(true, for: deviceID)
        case .indeterminate:
            break
        }
    }

    private func saveHotKey() {
        guard let data = try? JSONEncoder().encode(hotKey) else { return }
        UserDefaults.standard.set(data, forKey: Self.hotKeyDefaultsKey)
    }

    private func registerHotKey() {
        do {
            try hotKeyManager.register(hotKey)
            hotKeyRegistrationError = nil
        } catch {
            hotKeyRegistrationError = error.localizedDescription
        }
    }
}
