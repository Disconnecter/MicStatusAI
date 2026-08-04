import SwiftUI

struct StatusOverlaySettingsView: View {
    @Binding var isEnabled: Bool
    @Binding var duration: StatusOverlayDuration
    @Binding var placement: StatusOverlayPlacement
    @Binding var transparency: Double

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                Toggle(L10n.overlayEnabled, isOn: $isEnabled)

                Picker(L10n.overlayDuration, selection: $duration) {
                    ForEach(StatusOverlayDuration.allCases) { option in
                        Text(option.displayName)
                            .tag(option)
                    }
                }
                .pickerStyle(.menu)
                .disabled(!isEnabled)

                Picker(L10n.overlayPlacement, selection: $placement) {
                    ForEach(StatusOverlayPlacement.allCases) { option in
                        Text(option.displayName)
                            .tag(option)
                    }
                }
                .pickerStyle(.menu)
                .disabled(!isEnabled)

                LabeledContent {
                    HStack(spacing: 8) {
                        Slider(
                            value: $transparency,
                            in: StatusOverlayTransparency.range,
                            step: StatusOverlayTransparency.step
                        ) {
                            Text(L10n.overlayTransparency)
                        }
                        .labelsHidden()
                        .accessibilityLabel(L10n.overlayTransparency)
                        .accessibilityValue(
                            Text(
                                transparency,
                                format: .percent.precision(.fractionLength(0))
                            )
                        )

                        Text(
                            transparency,
                            format: .percent.precision(.fractionLength(0))
                        )
                        .monospacedDigit()
                        .frame(minWidth: 42, alignment: .trailing)
                        .accessibilityHidden(true)
                    }
                } label: {
                    Text(L10n.overlayTransparency)
                }
                .disabled(!isEnabled)

                Text(L10n.overlayHelp)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 4)
        } label: {
            Text(L10n.overlayTitle)
        }
    }
}
