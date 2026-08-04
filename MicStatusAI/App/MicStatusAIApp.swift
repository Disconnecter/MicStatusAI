import SwiftUI

@main
struct MicStatusAIApp: App {
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
