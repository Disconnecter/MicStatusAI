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
        toolTip = L10n.hotkeyTooltip
        setAccessibilityLabel(L10n.hotkeyAccessibility)
        setAccessibilityValue(configuration.displayName)
    }

    func beginRecording() {
        isRecording = true
        title = L10n.hotkeyPrompt
        toolTip = L10n.hotkeyCancel
        setAccessibilityValue(L10n.hotkeyRecording)
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
