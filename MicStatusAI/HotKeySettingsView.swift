import SwiftUI

struct HotKeySettingsView: View {
    @Bindable var model: MicrophoneStatusModel

    var body: some View {
        Form {
            Section("Mute / Unmute Hotkey") {
                LabeledContent("Current shortcut") {
                    Text(model.hotKey.displayName)
                        .font(.title2.monospaced())
                        .accessibilityLabel("Current shortcut: \(model.hotKey.displayName)")
                }

                Picker("Key", selection: $model.hotKey.keyCode) {
                    ForEach(KeyChoice.all) { key in
                        Text(key.name).tag(key.code)
                    }
                }

                Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 8) {
                    GridRow {
                        Toggle("Control (⌃)", isOn: $model.hotKey.usesControl)
                        Toggle("Option (⌥)", isOn: $model.hotKey.usesOption)
                    }
                    GridRow {
                        Toggle("Shift (⇧)", isOn: $model.hotKey.usesShift)
                        Toggle("Command (⌘)", isOn: $model.hotKey.usesCommand)
                    }
                }

                if let error = model.hotKeyRegistrationError {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                } else {
                    Label("Shortcut active system-wide", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }

                HStack {
                    Spacer()
                    Button("Restore Default") {
                        model.restoreDefaultHotKey()
                    }
                }
            }
        }
        .formStyle(.grouped)
        .scenePadding()
        .frame(width: 430, height: 330)
    }
}
