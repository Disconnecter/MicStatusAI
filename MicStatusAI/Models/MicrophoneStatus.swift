import AppKit
import SwiftUI

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
            "mic.slash.fill"
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
            let percentage = Double(volume).formatted(
                .percent.precision(.fractionLength(0))
            )
            return L10n.statusOn(percentage)
        case .muted:
            return L10n.statusMuted
        case .stopped:
            return L10n.monitoringOff
        case .unavailable:
            return L10n.statusUnavailable
        }
    }

    var accessibilityLabel: String {
        menuTitle
    }

    var muteState: MicrophoneMuteState {
        switch self {
        case .active:
            .active
        case .muted:
            .muted
        case .stopped, .unavailable:
            .indeterminate
        }
    }

    var errorMessage: String? {
        guard case let .unavailable(message) = self else { return nil }
        return message
    }
}
