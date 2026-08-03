import SwiftUI

struct StatusPanel: View {
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
                    Text(
                        model.isMonitoring
                            ? L10n.monitoringActive
                            : L10n.monitoringPaused
                    )
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

            GroupBox {
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
                        Text(L10n.inputAccessibility)
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
            } label: {
                Text(L10n.inputTitle)
            }

            HStack {
                Button {
                    model.toggleMonitoring()
                } label: {
                    Text(model.isMonitoring ? L10n.actionStop : L10n.actionStart)
                }

                Spacer()

                Button {
                    model.toggleMute()
                } label: {
                    Text(model.isMuted ? L10n.actionUnmute : L10n.actionMute)
                }
                .disabled(model.status.errorMessage != nil)
            }

            Divider()

            HStack {
                SettingsLink {
                    Label {
                        Text(L10n.hotkeySettings)
                    } icon: {
                        Image(systemName: "keyboard")
                    }
                }

                Spacer()

                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Text(L10n.actionQuit)
                }
                .keyboardShortcut("q")
            }
        }
        .padding(14)
        .frame(width: 330)
    }
}
