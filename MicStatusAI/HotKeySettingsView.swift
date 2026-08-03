import SwiftUI

struct HotKeySettingsView: View {
    @Bindable var model: MicrophoneStatusModel
    @State private var recordingError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label("Mute / Unmute Hotkey", systemImage: "keyboard")
                .font(.title2.bold())

            Text("Click shortcut field, then press new combination. Shortcut must contain at least two modifier keys and one letter or number.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            GroupBox {
                LabeledContent("Keyboard Shortcut") {
                    HotKeyRecorderView(
                        configuration: model.hotKey,
                        onChange: { model.hotKey = $0 },
                        onValidationError: { recordingError = $0 }
                    )
                    .frame(width: 170, height: 28)
                }
                .padding(.vertical, 4)
            }

            if let error = recordingError ?? model.hotKeyRegistrationError {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.callout)
                    .foregroundStyle(.orange)
            } else {
                Label("\(model.hotKey.displayName) active system-wide", systemImage: "checkmark.circle.fill")
                    .font(.callout)
                    .foregroundStyle(.green)
            }

            Divider()

            HStack {
                Text("Press Escape while recording to cancel.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Restore Default") {
                    recordingError = nil
                    model.restoreDefaultHotKey()
                }
            }
        }
        .scenePadding()
        .frame(width: 480, height: 280)
    }
}
