import Carbon.HIToolbox

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
            usesCommand ? "⌘" : nil,
        ].compactMap { $0 }.joined(separator: " ")

        let keyName = KeyChoice.all.first(where: { $0.code == keyCode })?.name ?? "?"
        return "\(modifiers) \(keyName)"
    }
}
