import AppKit
import Carbon.HIToolbox
import SwiftUI

struct HotKeyRecorderView: NSViewRepresentable {
    let configuration: HotKeyConfiguration
    let onChange: (HotKeyConfiguration) -> Void
    let onValidationError: (String?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeNSView(context: Context) -> HotKeyRecorderButton {
        let button = HotKeyRecorderButton()
        button.bezelStyle = .rounded
        button.setButtonType(.momentaryPushIn)
        button.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .medium)
        button.target = context.coordinator
        button.action = #selector(Coordinator.beginRecording(_:))
        button.onKeyEvent = { [weak coordinator = context.coordinator, weak button] event in
            guard let coordinator, let button else { return }
            coordinator.record(event, in: button)
        }
        button.show(configuration)
        return button
    }

    func updateNSView(_ button: HotKeyRecorderButton, context: Context) {
        context.coordinator.parent = self
        guard !button.isRecording else { return }
        button.show(configuration)
    }

    @MainActor
    final class Coordinator: NSObject {
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
}

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
