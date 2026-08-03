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

private struct StatusPanel: View {
    let model: MicrophoneStatusModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: model.status.symbolName)
                    .font(.title2)
                    .foregroundStyle(model.status.color)
                    .frame(width: 28)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(model.status.menuTitle)
                        .font(.headline)
                    Text(model.isMonitoring ? "Monitoring default microphone" : "Monitoring paused")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)

            if let message = model.status.errorMessage {
                Label(message, systemImage: "exclamationmark.triangle.fill")
                    .font(.callout)
                    .foregroundStyle(.orange)
            }

            GroupBox("Input Level") {
                HStack(spacing: 10) {
                    Image(systemName: "mic.slash.fill")
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)

                    Slider(
                        value: Binding(
                            get: { model.inputLevel },
                            set: { model.setInputLevel($0) }
                        ),
                        in: 0 ... 1
                    ) {
                        Text("Microphone input level")
                    }
                    .tint(model.inputLevel > 0 ? .green : .red)
                    .disabled(!model.canAdjustInputLevel)
                    .accessibilityValue(
                        Text(model.inputLevel, format: .percent.precision(.fractionLength(0)))
                    )

                    Text(model.inputLevel, format: .percent.precision(.fractionLength(0)))
                        .monospacedDigit()
                        .frame(width: 38, alignment: .trailing)
                }
                .padding(.vertical, 4)
            }

            HStack {
                Button(model.isMonitoring ? "Stop Monitoring" : "Start Monitoring") {
                    model.toggleMonitoring()
                }

                Spacer()

                Button(model.isMuted ? "Unmute" : "Mute") {
                    model.toggleMute()
                }
                .disabled(model.status.errorMessage != nil)
            }

            Divider()

            HStack {
                SettingsLink {
                    Label("Hotkey Settings…", systemImage: "keyboard")
                }

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
            }
        }
        .padding(14)
        .frame(width: 330)
    }
}
