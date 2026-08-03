import Carbon.HIToolbox
import Foundation

enum HotKeyError: LocalizedError {
    case twoModifiersRequired
    case registrationFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .twoModifiersRequired:
            L10n.errorInvalidHotkey
        case let .registrationFailed(status):
            L10n.errorHotkeyRegistration(Int(status))
        }
    }
}
