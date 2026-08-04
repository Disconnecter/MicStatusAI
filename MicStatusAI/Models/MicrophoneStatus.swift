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

    private var statusBarAssetName: String {
        switch self {
        case .active:
            "StatusBarActive"
        case .muted:
            "StatusBarMuted"
        case .stopped:
            "StatusBarStopped"
        case .unavailable:
            "StatusBarUnavailable"
        }
    }

    @MainActor var statusBarImage: NSImage {
        let assetName = NSImage.Name(statusBarAssetName)
        guard let sourceImage = NSImage(named: assetName),
              let image = sourceImage.copy() as? NSImage
        else {
            assertionFailure("Missing status bar image asset: \(statusBarAssetName)")
            return NSImage()
        }

        image.size = NSSize(width: 18, height: 18)
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
