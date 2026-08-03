import SwiftUI

struct HotKeySettingsView: View {
    @Bindable var model: MicrophoneStatusModel
    @State private var recordingError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label {
                Text(L10n.muteUnmuteHotKey)
            } icon: {
                Image(systemName: "keyboard")
            }
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
                Label {
                    Text(L10n.hotKeyActive(displayName: model.hotKey.displayName))
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                }
                .font(.callout)
                .foregroundStyle(.green)
            }

            Divider()

            HStack {
                Text(L10n.pressEscapeWhileRecording)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    recordingError = nil
                    model.restoreDefaultHotKey()
                } label: {
                    Text(L10n.restoreDefault)
                }
            }
        }
        .scenePadding()
        .frame(width: 480, height: 280)
    }
}
