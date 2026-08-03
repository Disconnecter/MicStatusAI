import Carbon.HIToolbox
import Foundation

enum HotKeyError: LocalizedError {
    case twoModifiersRequired
    case registrationFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .twoModifiersRequired:
            String(localized: L10n.shortcutNeedsTwoModifiers)
        case let .registrationFailed(status):
            String(localized: L10n.hotKeyRegistrationFailed(status: status))
        }
    }
}
