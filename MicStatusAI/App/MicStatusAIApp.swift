import SwiftUI

@main
struct MicStatusAIApp: App {
    @State private var model = MicrophoneStatusModel()

    var body: some Scene {
        MenuBarExtra {
            StatusPanel(model: model)
        } label: {
            Image(nsImage: model.status.statusBarImage)
                .renderingMode(.original)
                .accessibilityLabel(model.status.accessibilityLabel)
        }
        .menuBarExtraStyle(.window)

        Settings {
            HotKeySettingsView(model: model)
        }
    }
}
