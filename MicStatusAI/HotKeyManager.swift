import Carbon.HIToolbox
import Foundation

struct HotKeyConfiguration: Codable, Equatable {
    var keyCode: UInt32
    var usesControl: Bool
    var usesOption: Bool
    var usesCommand: Bool
    var usesShift: Bool

    static let defaultValue = HotKeyConfiguration(
        keyCode: UInt32(kVK_ANSI_M),
        usesControl: true,
        usesOption: true,
        usesCommand: false,
        usesShift: false
    )

    var modifierCount: Int {
        [usesControl, usesOption, usesCommand, usesShift].filter { $0 }.count
    }

    var carbonModifiers: UInt32 {
        var modifiers = 0
        if usesControl {
            modifiers |= controlKey
        }
        if usesOption {
            modifiers |= optionKey
        }
        if usesCommand {
            modifiers |= cmdKey
        }
        if usesShift {
            modifiers |= shiftKey
        }
        return UInt32(modifiers)
    }

    var displayName: String {
        let modifiers = [
            usesControl ? "⌃" : nil,
            usesOption ? "⌥" : nil,
            usesShift ? "⇧" : nil,
            usesCommand ? "⌘" : nil
        ].compactMap { $0 }.joined(separator: " ")

        let keyName = KeyChoice.all.first(where: { $0.code == keyCode })?.name ?? "?"
        return "\(modifiers) \(keyName)"
    }
}

struct KeyChoice: Identifiable, Hashable {
    let name: String
    let code: UInt32

    var id: UInt32 {
        code
    }

    static let all: [KeyChoice] = [
        KeyChoice(name: "A", code: UInt32(kVK_ANSI_A)),
        KeyChoice(name: "B", code: UInt32(kVK_ANSI_B)),
        KeyChoice(name: "C", code: UInt32(kVK_ANSI_C)),
        KeyChoice(name: "D", code: UInt32(kVK_ANSI_D)),
        KeyChoice(name: "E", code: UInt32(kVK_ANSI_E)),
        KeyChoice(name: "F", code: UInt32(kVK_ANSI_F)),
        KeyChoice(name: "G", code: UInt32(kVK_ANSI_G)),
        KeyChoice(name: "H", code: UInt32(kVK_ANSI_H)),
        KeyChoice(name: "I", code: UInt32(kVK_ANSI_I)),
        KeyChoice(name: "J", code: UInt32(kVK_ANSI_J)),
        KeyChoice(name: "K", code: UInt32(kVK_ANSI_K)),
        KeyChoice(name: "L", code: UInt32(kVK_ANSI_L)),
        KeyChoice(name: "M", code: UInt32(kVK_ANSI_M)),
        KeyChoice(name: "N", code: UInt32(kVK_ANSI_N)),
        KeyChoice(name: "O", code: UInt32(kVK_ANSI_O)),
        KeyChoice(name: "P", code: UInt32(kVK_ANSI_P)),
        KeyChoice(name: "Q", code: UInt32(kVK_ANSI_Q)),
        KeyChoice(name: "R", code: UInt32(kVK_ANSI_R)),
        KeyChoice(name: "S", code: UInt32(kVK_ANSI_S)),
        KeyChoice(name: "T", code: UInt32(kVK_ANSI_T)),
        KeyChoice(name: "U", code: UInt32(kVK_ANSI_U)),
        KeyChoice(name: "V", code: UInt32(kVK_ANSI_V)),
        KeyChoice(name: "W", code: UInt32(kVK_ANSI_W)),
        KeyChoice(name: "X", code: UInt32(kVK_ANSI_X)),
        KeyChoice(name: "Y", code: UInt32(kVK_ANSI_Y)),
        KeyChoice(name: "Z", code: UInt32(kVK_ANSI_Z)),
        KeyChoice(name: "0", code: UInt32(kVK_ANSI_0)),
        KeyChoice(name: "1", code: UInt32(kVK_ANSI_1)),
        KeyChoice(name: "2", code: UInt32(kVK_ANSI_2)),
        KeyChoice(name: "3", code: UInt32(kVK_ANSI_3)),
        KeyChoice(name: "4", code: UInt32(kVK_ANSI_4)),
        KeyChoice(name: "5", code: UInt32(kVK_ANSI_5)),
        KeyChoice(name: "6", code: UInt32(kVK_ANSI_6)),
        KeyChoice(name: "7", code: UInt32(kVK_ANSI_7)),
        KeyChoice(name: "8", code: UInt32(kVK_ANSI_8)),
        KeyChoice(name: "9", code: UInt32(kVK_ANSI_9))
    ]
}

@MainActor
final class HotKeyManager {
    var onPressed: (() -> Void)?

    private nonisolated(unsafe) var hotKeyReference: EventHotKeyRef?
    private nonisolated(unsafe) var eventHandlerReference: EventHandlerRef?
    private let hotKeyID = EventHotKeyID(signature: OSType(0x4D53_4149), id: 1)

    init() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let context = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, context in
                guard let context else { return OSStatus(eventNotHandledErr) }
                let manager = Unmanaged<HotKeyManager>.fromOpaque(context).takeUnretainedValue()
                MainActor.assumeIsolated {
                    manager.onPressed?()
                }
                return noErr
            },
            1,
            &eventType,
            context,
            &eventHandlerReference
        )
    }

    deinit {
        if let hotKeyReference {
            UnregisterEventHotKey(hotKeyReference)
        }
        if let eventHandlerReference {
            RemoveEventHandler(eventHandlerReference)
        }
    }

    func register(_ configuration: HotKeyConfiguration) throws {
        if let hotKeyReference {
            UnregisterEventHotKey(hotKeyReference)
            self.hotKeyReference = nil
        }

        guard configuration.modifierCount >= 2 else {
            throw HotKeyError.twoModifiersRequired
        }

        var newReference: EventHotKeyRef?
        let status = RegisterEventHotKey(
            configuration.keyCode,
            configuration.carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &newReference
        )
        guard status == noErr, let newReference else {
            throw HotKeyError.registrationFailed(status)
        }
        hotKeyReference = newReference
    }
}

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
