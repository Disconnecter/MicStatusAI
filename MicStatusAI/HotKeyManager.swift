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

    var carbonModifiers: UInt32 {
        var modifiers = 0
        if usesControl { modifiers |= controlKey }
        if usesOption { modifiers |= optionKey }
        if usesCommand { modifiers |= cmdKey }
        if usesShift { modifiers |= shiftKey }
        return UInt32(modifiers)
    }

    var displayName: String {
        let modifiers = [
            usesControl ? "⌃" : nil,
            usesOption ? "⌥" : nil,
            usesShift ? "⇧" : nil,
            usesCommand ? "⌘" : nil
        ].compactMap { $0 }.joined()

        let keyName = KeyChoice.all.first(where: { $0.code == keyCode })?.name ?? "?"
        return modifiers + keyName
    }
}

struct KeyChoice: Identifiable, Hashable {
    let name: String
    let code: UInt32

    var id: UInt32 { code }

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
        KeyChoice(name: "Z", code: UInt32(kVK_ANSI_Z))
    ]
}

@MainActor
final class HotKeyManager {
    var onPressed: (() -> Void)?

    nonisolated(unsafe) private var hotKeyReference: EventHotKeyRef?
    nonisolated(unsafe) private var eventHandlerReference: EventHandlerRef?
    private let hotKeyID = EventHotKeyID(signature: OSType(0x4D_53_41_49), id: 1)

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

        guard configuration.carbonModifiers != 0 else {
            throw HotKeyError.modifierRequired
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
    case modifierRequired
    case registrationFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .modifierRequired:
            "Select at least one modifier key."
        case let .registrationFailed(status):
            "Could not register hotkey (error \(status)). Another app may use it."
        }
    }
}
