import SwiftUI

struct HotKeySettingsView: View {
    @Bindable var model: MicrophoneStatusModel
    @Binding var statusOverlayEnabled: Bool
    @Binding var statusOverlayDuration: StatusOverlayDuration
    @Binding var statusOverlayPlacement: StatusOverlayPlacement
    @Binding var statusOverlayTransparency: Double
    @State private var recordingError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label {
                Text(L10n.settingsTitle)
            } icon: {
                Image(systemName: "gearshape")
            }
            .font(.title2.bold())

            Text(L10n.hotkeyInstructions)
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
                    Text(L10n.hotkeyLabel)
                }
                .padding(.vertical, 4)
            } label: {
                Text(L10n.hotkeyTitle)
            }

            if let error = recordingError ?? model.hotKeyRegistrationError {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.callout)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Label {
                    Text(L10n.hotkeyActive(model.hotKey.displayName))
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                }
                .font(.callout)
                .foregroundStyle(.green)
            }

            StatusOverlaySettingsView(
                isEnabled: $statusOverlayEnabled,
                duration: $statusOverlayDuration,
                placement: $statusOverlayPlacement,
                transparency: $statusOverlayTransparency
            )

            Divider()

            HStack {
                Text(L10n.hotkeyCancelHelp)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    recordingError = nil
                    model.restoreDefaultHotKey()
                } label: {
                    Text(L10n.actionRestoreHotkey)
                }
            }
        }
        .scenePadding()
        .frame(minWidth: 480, idealWidth: 480, minHeight: 450)
    }
}
