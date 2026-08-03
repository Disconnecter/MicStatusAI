import SwiftUI

struct HotKeySettingsView: View {
    @Bindable var model: MicrophoneStatusModel
    @State private var recordingError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label(L10n.muteUnmuteHotKey, systemImage: "keyboard")
                .font(.title2.bold())

            Text(L10n.shortcutInstructions)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            GroupBox {
                LabeledContent {
                    HotKeyRecorderView(
                        configuration: model.hotKey,
                        onChange: { model.hotKey = $0 },
                        onValidationError: { recordingError = $0 }
                    )
                    .frame(width: 170, height: 28)
                } label: {
                    Text(L10n.keyboardShortcut)
                }
                .padding(.vertical, 4)
            }

            if let error = recordingError ?? model.hotKeyRegistrationError {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.callout)
                    .foregroundStyle(.orange)
            } else {
                Label(
                    L10n.hotKeyActive(displayName: model.hotKey.displayName),
                    systemImage: "checkmark.circle.fill"
                )
                    .font(.callout)
                    .foregroundStyle(.green)
            }

            Divider()

            HStack {
                Text(L10n.pressEscapeWhileRecording)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(L10n.restoreDefault) {
                    recordingError = nil
                    model.restoreDefaultHotKey()
                }
            }
        }
        .scenePadding()
        .frame(width: 480, height: 280)
    }
}
