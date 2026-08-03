import SwiftUI

@main
struct MicStatusAIApp: App {
    @State private var model = MicrophoneStatusModel()

    var body: some Scene {
        MenuBarExtra {
            StatusMenu(model: model)
        } label: {
            Image(nsImage: model.status.statusBarImage)
                .renderingMode(.original)
                .accessibilityLabel(model.status.accessibilityLabel)
        }
        .menuBarExtraStyle(.menu)

        Settings {
            HotKeySettingsView(model: model)
        }
    }
}

private struct StatusMenu: View {
    let model: MicrophoneStatusModel

    var body: some View {
        Label(model.status.menuTitle, systemImage: model.status.symbolName)
            .foregroundStyle(model.status.color)

        if let message = model.status.errorMessage {
            Text(message)
        }

        Divider()

        Button(model.isMonitoring ? "Stop Monitoring" : "Start Monitoring") {
            model.toggleMonitoring()
        }

        Button(model.isMuted ? "Unmute Microphone" : "Mute Microphone") {
            model.toggleMute()
        }

        Divider()

        SettingsLink {
            Label("Hotkey Settings…", systemImage: "keyboard")
        }

        Divider()

        Button("Quit MicStatusAI") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
