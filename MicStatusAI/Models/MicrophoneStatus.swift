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

    @MainActor var statusBarImage: NSImage {
        let iconSize = 18.0
        let renderer = ImageRenderer(
            content: Image(systemName: symbolName)
                .symbolRenderingMode(.monochrome)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: iconSize, height: iconSize)
        )
        renderer.scale = NSScreen.main?.backingScaleFactor ?? 2

        guard let image = renderer.nsImage else {
            let fallbackImage = NSImage(
                systemSymbolName: symbolName,
                accessibilityDescription: accessibilityLabel
            ) ?? NSImage()
            fallbackImage.isTemplate = true
            return fallbackImage
        }

        image.isTemplate = false
        return image
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
