import SwiftUI

struct HotKeySettingsView: View {
    @Bindable var model: MicrophoneStatusModel
    @Binding var statusOverlayEnabled: Bool
    @Binding var statusOverlayDuration: StatusOverlayDuration
    @Binding var statusOverlayPlacement: StatusOverlayPlacement
    @Binding var statusOverlayTransparency: Double
    @State private var recordingError: String?

    private static let appVersion = Bundle.main.object(
        forInfoDictionaryKey: "CFBundleShortVersionString"
    ) as? String ?? "—"
    private static let xProfileURL = URL(string: "https://x.com/disconnecter")!
    private static let gitHubURL = URL(string: "https://github.com/Disconnecter/MicStatusAI")!

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

            GroupBox {
                ViewThatFits(in: .horizontal) {
                    HStack {
                        versionLabel
                        Spacer()
                        projectLinks
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        versionLabel
                        projectLinks
                    }
                }
                .padding(.vertical, 4)
            } label: {
                Text(L10n.settingsAbout)
            }

            Divider()

            ViewThatFits(in: .horizontal) {
                HStack {
                    cancelHelp
                    Spacer()
                    restoreHotKeyButton
                }

                VStack(alignment: .leading, spacing: 8) {
                    cancelHelp
                    restoreHotKeyButton
                }
            }
        }
        .scenePadding()
        .frame(minWidth: 320, idealWidth: 340, maxWidth: 360)
    }

    private var hotKeyRecorder: some View {
        HotKeyRecorderView(
            configuration: model.hotKey,
            onChange: { model.hotKey = $0 },
            onValidationError: { recordingError = $0 }
        )
        .frame(width: 170, height: 28)
    }

    private var versionLabel: some View {
        Text(L10n.settingsVersion(Self.appVersion))
            .foregroundStyle(.secondary)
    }

    private var projectLinks: some View {
        HStack {
            Link(destination: Self.xProfileURL) {
                Label {
                    Text(L10n.settingsXProfile)
                } icon: {
                    Image(systemName: "at")
                }
            }
            .buttonStyle(.bordered)

            Link(destination: Self.gitHubURL) {
                Label {
                    Text(L10n.settingsGithub)
                } icon: {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                }
            }
            .buttonStyle(.bordered)
        }
    }

    private var cancelHelp: some View {
        Text(L10n.hotkeyCancelHelp)
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    private var restoreHotKeyButton: some View {
        Button {
            recordingError = nil
            model.restoreDefaultHotKey()
        } label: {
            Text(L10n.actionRestoreHotkey)
        }
    }
}
