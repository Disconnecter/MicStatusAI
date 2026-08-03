import Carbon.HIToolbox
import Foundation

enum HotKeyError: LocalizedError {
    case twoModifiersRequired
    case registrationFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .twoModifiersRequired:
            "Shortcut needs at least two modifier keys and one letter or number."
        case let .registrationFailed(status):
            "Could not register hotkey (error \(status)). Another app may use it."
        }
    }
}
