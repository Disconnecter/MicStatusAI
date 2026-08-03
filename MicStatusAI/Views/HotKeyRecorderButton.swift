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
        toolTip = String(localized: L10n.shortcutToolTip)
        setAccessibilityLabel(String(localized: L10n.shortcutAccessibilityLabel))
        setAccessibilityValue(configuration.displayName)
    }

    func beginRecording() {
        isRecording = true
        title = String(localized: L10n.pressShortcut)
        toolTip = String(localized: L10n.pressEscapeToCancel)
        setAccessibilityValue(String(localized: L10n.recordingAccessibilityValue))
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
