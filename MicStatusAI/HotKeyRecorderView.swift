import AppKit
import SwiftUI

struct HotKeyRecorderView: NSViewRepresentable {
    let configuration: HotKeyConfiguration
    let onChange: (HotKeyConfiguration) -> Void
    let onValidationError: (String?) -> Void

    func makeCoordinator() -> HotKeyRecorderCoordinator {
        HotKeyRecorderCoordinator(parent: self)
    }

    func makeNSView(context: Context) -> HotKeyRecorderButton {
        let button = HotKeyRecorderButton()
        button.bezelStyle = .rounded
        button.setButtonType(.momentaryPushIn)
        button.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .medium)
        button.target = context.coordinator
        button.action = #selector(HotKeyRecorderCoordinator.beginRecording(_:))
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
}
