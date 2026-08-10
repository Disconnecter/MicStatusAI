import PostHog
import SwiftUI

@main
struct MicStatusAIApp: App {
    init() {
        let environment = ProcessInfo.processInfo.environment
        let projectToken = environment["POSTHOG_PROJECT_TOKEN"]
            ?? Bundle.main.object(forInfoDictionaryKey: "POSTHOG_PROJECT_TOKEN") as? String
        guard let projectToken, !projectToken.isEmpty else {
            #if DEBUG
            fatalError(
                "POSTHOG_PROJECT_TOKEN variable required by PostHog is missing or un-configured, "
                    + "this causes events to be silently missed. This error stops appearing once "
                    + "POSTHOG_PROJECT_TOKEN is configured"
            )
            #else
            return
            #endif
        }

        let host = environment["POSTHOG_HOST"]
            ?? Bundle.main.object(forInfoDictionaryKey: "POSTHOG_HOST") as? String
        guard let host, !host.isEmpty else {
            #if DEBUG
            fatalError(
                "POSTHOG_HOST variable required by PostHog is missing or un-configured, this causes "
                    + "events to be silently missed. This error stops appearing once POSTHOG_HOST is configured"
            )
            #else
            return
            #endif
        }

        let config = PostHogConfig(apiKey: projectToken, host: host)
        config.errorTrackingConfig.autoCapture = true
        PostHogSDK.shared.setup(config)
    }

    @AppStorage("statusOverlayEnabled")
    private var statusOverlayEnabled = true
    @AppStorage("statusOverlayDuration")
    private var statusOverlayDuration: StatusOverlayDuration = .oneSecond
    @AppStorage("statusOverlayPlacement")
    private var statusOverlayPlacement: StatusOverlayPlacement = .center
    @AppStorage("statusOverlayTransparency")
    private var statusOverlayTransparency = StatusOverlayTransparency.defaultValue
    @State private var model = MicrophoneStatusModel()
    @State private var statusOverlayPresenter = StatusOverlayPresenter()

    var body: some Scene {
        MenuBarExtra {
            StatusPanel(model: model)
        } label: {
            Image(nsImage: model.status.statusBarImage)
                .renderingMode(.original)
                .accessibilityLabel(model.status.accessibilityLabel)
                .onChange(of: model.status.muteState) { previousState, currentState in
                    guard statusOverlayEnabled,
                          previousState != .indeterminate,
                          currentState != .indeterminate,
                          previousState != currentState else { return }
                    statusOverlayPresenter.show(
                        status: model.status,
                        duration: statusOverlayDuration.seconds,
                        placement: statusOverlayPlacement,
                        transparency: statusOverlayTransparency
                    )
                }
                .onChange(of: statusOverlayEnabled) { _, isEnabled in
                    if !isEnabled {
                        statusOverlayPresenter.dismiss()
                    }
                }
        }
        .menuBarExtraStyle(.window)

        Settings {
            HotKeySettingsView(
                model: model,
                statusOverlayEnabled: $statusOverlayEnabled,
                statusOverlayDuration: $statusOverlayDuration,
                statusOverlayPlacement: $statusOverlayPlacement,
                statusOverlayTransparency: $statusOverlayTransparency
            )
        }
    }
}
