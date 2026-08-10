import SwiftUI

struct HotKeySettingsView: View {
    @Bindable var model: MicrophoneStatusModel
    @Binding var statusOverlayEnabled: Bool
    @Binding var statusOverlayDuration: StatusOverlayDuration
    @Binding var statusOverlayPlacement: StatusOverlayPlacement
    @Binding var statusOverlayTransparency: Double
    let onShowOverlayPreview: () -> Void

    @State private var recordingError: String?

    private static let appVersion = Bundle.main.object(
        forInfoDictionaryKey: "CFBundleShortVersionString"
    ) as? String ?? "—"
    private static let xProfileURL = URL(string: "https://x.com/disconnecter")!
    private static let gitHubURL = URL(string: "https://github.com/Disconnecter/MicStatusAI")!

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(L10n.settingsTitle)
            } icon: {
                Image(systemName: "gearshape")
            }
            .font(.title2.bold())

            Form {
                Section {
                    Text(L10n.hotkeyInstructions)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    shortcutControl
                    hotKeyStatus
                    shortcutActions
                } header: {
                    Text(L10n.hotkeyTitle)
                }

                StatusOverlaySettingsView(
                    isEnabled: $statusOverlayEnabled,
                    duration: $statusOverlayDuration,
                    placement: $statusOverlayPlacement,
                    transparency: $statusOverlayTransparency,
                    onShowPreview: onShowOverlayPreview
                )

                Section {
                    aboutContent
                } header: {
                    Text(L10n.settingsAbout)
                }
            }
            .formStyle(.grouped)
        }
        .scenePadding()
        .frame(minWidth: 320, idealWidth: 340, maxWidth: 360)
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
            configuration: model.hotKey,
            onChange: { model.hotKey = $0 },
            onValidationError: { recordingError = $0 }
        )
        .frame(width: 170, height: 28)
    }

    @ViewBuilder private var hotKeyStatus: some View {
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
    }

    private var shortcutActions: some View {
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

    private var aboutContent: some View {
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
}
