import SwiftUI

struct HotKeySettingsView: View {
    @Bindable var model: MicrophoneStatusModel
    @Binding var statusOverlayEnabled: Bool
    @Binding var statusOverlayDuration: StatusOverlayDuration
    @Binding var statusOverlayPlacement: StatusOverlayPlacement
    @Binding var statusOverlayTransparency: Double
    @Binding var analyticsEnabled: Bool
    let analytics: any AnalyticsTracking
    let onShowOverlayPreview: () -> Void

    @State private var recordingError: String?
    @State private var isRecordingHotKey = false

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
                    analytics: analytics,
                    onShowPreview: onShowOverlayPreview
                )

                Section {
                    Toggle(L10n.analyticsEnabled, isOn: $analyticsEnabled)
                        .onChange(of: analyticsEnabled) { _, isEnabled in
                            analytics.setEnabled(isEnabled)
                            if isEnabled {
                                analytics.track(.analyticsEnabled)
                            }
                        }
                } header: {
                    Text(L10n.analyticsTitle)
                } footer: {
                    Text(L10n.analyticsHelp)
                }

                Section {
                    aboutContent
                } header: {
                    Text(L10n.settingsAbout)
                }
            }
            .formStyle(.grouped)
        }
        .scenePadding()
        .frame(minWidth: 400, idealWidth: 420, maxWidth: 500)
        .onAppear {
            analytics.track(.settingsOpened)
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
            configuration: model.hotKey,
            isRecording: $isRecordingHotKey,
            onChange: { model.hotKey = $0 },
            onValidationError: { recordingError = $0 }
        )
        .frame(width: 170, height: 28)
    }

    @ViewBuilder private var hotKeyStatus: some View {
        if isRecordingHotKey {
            Label {
                Text(L10n.hotkeyRecordingStatus)
            } icon: {
                Image(systemName: "record.circle.fill")
            }
            .font(.callout)
            .foregroundStyle(.red)
            .accessibilityLabel(L10n.hotkeyRecording)
        } else if let error = recordingError ?? model.hotKeyRegistrationError {
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

    @ViewBuilder private var shortcutActions: some View {
        if isRecordingHotKey {
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
            isRecordingHotKey = false
        } label: {
            Text(L10n.actionCancel)
        }
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
