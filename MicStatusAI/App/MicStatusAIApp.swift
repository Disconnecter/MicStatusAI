import SwiftUI

@main
@MainActor
struct MicStatusAIApp: App {
    @AppStorage("statusOverlayEnabled")
    private var statusOverlayEnabled = true
    @AppStorage("statusOverlayDuration")
    private var statusOverlayDuration: StatusOverlayDuration = .oneSecond
    @AppStorage("statusOverlayPlacement")
    private var statusOverlayPlacement: StatusOverlayPlacement = .center
    @AppStorage("statusOverlayTransparency")
    private var statusOverlayTransparency = StatusOverlayTransparency.defaultValue
    @AppStorage("analyticsEnabled")
    private var analyticsEnabled = true

    @State private var model: MicrophoneStatusModel
    @State private var statusOverlayPresenter = StatusOverlayPresenter()

    private let analytics: AptabaseAnalytics

    init() {
        let isAnalyticsEnabled = UserDefaults.standard.object(
            forKey: "analyticsEnabled"
        ) as? Bool ?? true
        let analyticsClient = AptabaseAnalytics(
            appKey: AptabaseAnalytics.configuredAppKey(),
            isEnabled: isAnalyticsEnabled
        )

        analytics = analyticsClient
        _model = State(initialValue: MicrophoneStatusModel(analytics: analyticsClient))
        analyticsClient.track(.appLaunched)
    }

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
                    analytics.track(.overlayShown)
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
                statusOverlayTransparency: $statusOverlayTransparency,
                analyticsEnabled: $analyticsEnabled,
                analytics: analytics,
                onShowOverlayPreview: showOverlayPreview
            )
        }
        .windowResizability(.contentSize)
    }

    private func showOverlayPreview() {
        statusOverlayPresenter.show(
            status: model.status,
            duration: statusOverlayDuration.seconds,
            placement: statusOverlayPlacement,
            transparency: statusOverlayTransparency
        )
        analytics.track(.overlayPreviewed)
    }
}
