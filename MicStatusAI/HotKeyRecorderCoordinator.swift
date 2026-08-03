import AppKit
import Carbon.HIToolbox

@MainActor
final class HotKeyRecorderCoordinator: NSObject {
    var parent: HotKeyRecorderView

    init(parent: HotKeyRecorderView) {
        self.parent = parent
    }

    @objc func beginRecording(_ button: HotKeyRecorderButton) {
        parent.onValidationError(nil)
        button.beginRecording()
        button.window?.makeFirstResponder(button)
    }

    func record(_ event: NSEvent, in button: HotKeyRecorderButton) {
        guard !event.isARepeat else { return }

        if event.keyCode == UInt16(kVK_Escape) {
            button.finishRecording(with: parent.configuration)
            button.window?.makeFirstResponder(nil)
            parent.onValidationError(nil)
            return
        }

        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let configuration = HotKeyConfiguration(
            keyCode: UInt32(event.keyCode),
            usesControl: flags.contains(.control),
            usesOption: flags.contains(.option),
            usesCommand: flags.contains(.command),
            usesShift: flags.contains(.shift)
        )

        guard configuration.modifierCount >= 2 else {
            parent.onValidationError(
                "Press at least two modifier keys plus one letter or number."
            )
            return
        }

        guard KeyChoice.all.contains(where: { $0.code == configuration.keyCode }) else {
            parent.onValidationError("Use a letter or number as shortcut key.")
            return
        }

        parent.onValidationError(nil)
        parent.onChange(configuration)
        button.finishRecording(with: configuration)
        button.window?.makeFirstResponder(nil)
    }
}
