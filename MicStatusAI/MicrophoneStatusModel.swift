import Observation
import SwiftUI

@MainActor
@Observable
final class MicrophoneStatusModel {
    private(set) var status: MicrophoneStatus = .stopped
    private(set) var isMonitoring = false
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

    @ObservationIgnored private let microphone = CoreAudioMicrophone()
    @ObservationIgnored private let hotKeyManager = HotKeyManager()
    @ObservationIgnored private var pollingTimer: Timer?
    @ObservationIgnored private var lastNonzeroVolume: Float32

    private static let hotKeyDefaultsKey = "muteHotKey"
    private static let lastVolumeDefaultsKey = "lastNonzeroInputVolume"

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.hotKeyDefaultsKey),
           let savedHotKey = try? JSONDecoder().decode(HotKeyConfiguration.self, from: data)
        {
            hotKey = savedHotKey
        } else {
            hotKey = .defaultValue
        }

        let savedVolume = UserDefaults.standard.double(forKey: Self.lastVolumeDefaultsKey)
        lastNonzeroVolume = savedVolume > 0 ? Float32(savedVolume) : 0.5

        hotKeyManager.onPressed = { [weak self] in
            self?.toggleMute()
        }

        registerHotKey()
        startMonitoring()
    }

    func toggleMonitoring() {
        isMonitoring ? stopMonitoring() : startMonitoring()
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

    func toggleMute() {
        do {
            let currentVolume = try microphone.inputVolume()
            if currentVolume > 0 {
                lastNonzeroVolume = currentVolume
                UserDefaults.standard.set(Double(currentVolume), forKey: Self.lastVolumeDefaultsKey)
                try microphone.setInputVolume(0)
            } else {
                try microphone.setInputVolume(max(lastNonzeroVolume, 0.01))
            }

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
            let volume = try microphone.inputVolume()
            if volume > 0 {
                lastNonzeroVolume = volume
                UserDefaults.standard.set(Double(volume), forKey: Self.lastVolumeDefaultsKey)
                status = .active(volume)
            } else {
                status = .muted
            }
        } catch {
            status = .unavailable(error.localizedDescription)
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

enum MicrophoneStatus: Equatable {
    case active(Float32)
    case muted
    case stopped
    case unavailable(String)

    var symbolName: String {
        switch self {
        case .active:
            "mic.fill"
        case .muted:
            "mic.slash.fill"
        case .stopped, .unavailable:
            "mic.slash.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .active:
            .green
        case .muted:
            .red
        case .stopped:
            .secondary
        case .unavailable:
            .orange
        }
    }

    var statusBarImage: NSImage {
        let image = NSImage(
            systemSymbolName: symbolName,
            accessibilityDescription: accessibilityLabel
        ) ?? NSImage()
        let symbolColor: NSColor = switch self {
        case .active:
            .systemGreen
        case .muted:
            .systemRed
        case .stopped:
            .secondaryLabelColor
        case .unavailable:
            .systemOrange
        }
        let configuration = NSImage.SymbolConfiguration(paletteColors: [symbolColor])
        let configuredImage = image.withSymbolConfiguration(configuration) ?? image
        configuredImage.isTemplate = false
        return configuredImage
    }

    var menuTitle: String {
        switch self {
        case let .active(volume):
            "Microphone On · \(Int((volume * 100).rounded()))%"
        case .muted:
            "Microphone Muted"
        case .stopped:
            "Monitoring Off"
        case .unavailable:
            "Microphone Unavailable"
        }
    }

    var accessibilityLabel: String {
        menuTitle
    }

    var errorMessage: String? {
        guard case let .unavailable(message) = self else { return nil }
        return message
    }
}
