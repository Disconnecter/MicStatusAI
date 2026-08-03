import AppKit

@MainActor
final class HotKeyRecorderButton: NSButton {
    var onKeyEvent: ((NSEvent) -> Void)?
    private(set) var isRecording = false
    private var currentConfiguration = HotKeyConfiguration.defaultValue

    override var acceptsFirstResponder: Bool {
        true
    }

    func show(_ configuration: HotKeyConfiguration) {
        currentConfiguration = configuration
        title = configuration.displayName
        toolTip = "Click, then press a new shortcut"
        setAccessibilityLabel("Mute and unmute shortcut")
        setAccessibilityValue(configuration.displayName)
    }

    func beginRecording() {
        isRecording = true
        title = "Press shortcut…"
        toolTip = "Press Escape to cancel"
        setAccessibilityValue("Recording. Press at least two modifiers and one letter or number.")
    }

    func finishRecording(with configuration: HotKeyConfiguration) {
        isRecording = false
        show(configuration)
    }

    override func keyDown(with event: NSEvent) {
        guard isRecording else {
            super.keyDown(with: event)
            return
        }
        onKeyEvent?(event)
    }

    override func resignFirstResponder() -> Bool {
        if isRecording {
            isRecording = false
            show(currentConfiguration)
        }
        return super.resignFirstResponder()
    }
}
