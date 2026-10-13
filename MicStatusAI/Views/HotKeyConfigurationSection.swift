import SwiftUI

struct HotKeyConfigurationSection: View {
    let title: String
    let instructions: String
    let accessibilityLabel: String
    let configuration: HotKeyConfiguration
    let registrationError: String?
    @Binding var isRecording: Bool
    @Binding var recordingError: String?
    let onChange: (HotKeyConfiguration) -> Void
    let onRestore: () -> Void

    var body: some View {
        Section {
            Text(instructions)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            shortcutControl
            hotKeyStatus
            shortcutActions
        } header: {
            Text(title)
        }
    }

    private var shortcutControl: some View {
        ViewThatFits(in: .horizontal) {
            LabeledContent {
                hotKeyRecorder
            } label: {
                Text(L10n.hotkeyLabel)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.hotkeyLabel)
                hotKeyRecorder
            }
        }
    }

    private var hotKeyRecorder: some View {
        HotKeyRecorderView(
            configuration: configuration,
            accessibilityLabel: accessibilityLabel,
            isRecording: $isRecording,
            onChange: onChange
        ) {
            recordingError = $0
        }
        .frame(width: 170, height: 28)
    }

    @ViewBuilder private var hotKeyStatus: some View {
        if isRecording {
            Label {
                Text(L10n.hotkeyRecordingStatus)
            } icon: {
                Image(systemName: "record.circle.fill")
            }
            .font(.callout)
            .foregroundStyle(.red)
            .accessibilityLabel(L10n.hotkeyRecording)
        } else if let error = recordingError ?? registrationError {
            Label(error, systemImage: "exclamationmark.triangle.fill")
                .font(.callout)
                .foregroundStyle(.orange)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            Label {
                Text(L10n.hotkeyActive(configuration.displayName))
            } icon: {
                Image(systemName: "checkmark.circle.fill")
            }
            .font(.callout)
            .foregroundStyle(.green)
        }
    }

    @ViewBuilder private var shortcutActions: some View {
        if isRecording {
            ViewThatFits(in: .horizontal) {
                HStack {
                    cancelHelp
                    Spacer()
                    cancelRecordingButton
                }

                VStack(alignment: .leading, spacing: 8) {
                    cancelHelp
                    cancelRecordingButton
                }
            }
        } else {
            restoreHotKeyButton
        }
    }

    private var cancelHelp: some View {
        Text(L10n.hotkeyCancelHelp)
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    private var cancelRecordingButton: some View {
        Button {
            recordingError = nil
            isRecording = false
        } label: {
            Text(L10n.actionCancel)
        }
    }

    private var restoreHotKeyButton: some View {
        Button {
            recordingError = nil
            onRestore()
        } label: {
            Text(L10n.actionRestoreHotkey)
        }
    }
}
