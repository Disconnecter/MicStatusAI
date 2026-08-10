import AppKit

@MainActor
final class HotKeyRecorderButton: NSButton {
    var onKeyEvent: ((NSEvent) -> Void)?
    var onRecordingChange: ((Bool) -> Void)?

    private(set) var isRecording = false
    private var currentConfiguration = HotKeyConfiguration.defaultValue

    override var acceptsFirstResponder: Bool {
        true
    }

    func show(_ configuration: HotKeyConfiguration) {
        currentConfiguration = configuration
        title = configuration.displayName
        toolTip = L10n.hotkeyTooltip
        contentTintColor = nil
        setAccessibilityLabel(L10n.hotkeyAccessibility)
        setAccessibilityValue(configuration.displayName)
        setAccessibilityHelp(L10n.hotkeyTooltip)
    }

    func beginRecording() {
        setRecording(true)
        title = L10n.hotkeyPrompt
        toolTip = L10n.hotkeyCancel
        contentTintColor = .systemRed
        setAccessibilityValue(L10n.hotkeyRecording)
        setAccessibilityHelp(L10n.hotkeyCancel)
        NSAccessibility.post(element: self, notification: .valueChanged)
    }

    func finishRecording(with configuration: HotKeyConfiguration) {
        setRecording(false)
        show(configuration)
        NSAccessibility.post(element: self, notification: .valueChanged)
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
            finishRecording(with: currentConfiguration)
        }
        return super.resignFirstResponder()
    }

    private func setRecording(_ newValue: Bool) {
        guard isRecording != newValue else { return }
        isRecording = newValue
        onRecordingChange?(newValue)
    }
}
