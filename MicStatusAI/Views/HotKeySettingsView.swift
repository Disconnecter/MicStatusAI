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
    @State private var walkieTalkieRecordingError: String?
    @State private var isRecordingHotKey = false
    @State private var isRecordingWalkieTalkieHotKey = false

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
                HotKeyConfigurationSection(
                    title: L10n.hotkeyTitle,
                    instructions: L10n.hotkeyInstructions,
                    accessibilityLabel: L10n.hotkeyAccessibility,
                    configuration: model.hotKey,
                    registrationError: model.hotKeyRegistrationError,
                    isRecording: $isRecordingHotKey,
                    recordingError: $recordingError,
                    onChange: { model.hotKey = $0 },
                    onRestore: model.restoreDefaultHotKey
                )

                HotKeyConfigurationSection(
                    title: L10n.walkieTalkieTitle,
                    instructions: L10n.walkieTalkieInstructions,
                    accessibilityLabel: L10n.walkieTalkieAccessibility,
                    configuration: model.walkieTalkieHotKey,
                    registrationError: model.walkieTalkieHotKeyRegistrationError,
                    isRecording: $isRecordingWalkieTalkieHotKey,
                    recordingError: $walkieTalkieRecordingError,
                    onChange: { model.walkieTalkieHotKey = $0 },
                    onRestore: model.restoreDefaultWalkieTalkieHotKey
                )

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
