import SwiftUI

struct InputLevelControl: View {
    @Bindable var model: MicrophoneStatusModel

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Image(systemName: inputIconName)
                        .foregroundStyle(model.canAdjustInputLevel ? .secondary : .tertiary)
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
                    .disabled(!model.canAdjustInputLevel)
                    .accessibilityValue(
                        Text(model.inputLevel, format: .percent.precision(.fractionLength(0)))
                    )

                    Text(model.inputLevel, format: .percent.precision(.fractionLength(0)))
                        .monospacedDigit()
                        .frame(minWidth: 38, alignment: .trailing)
                        .accessibilityHidden(true)
                }

                if !model.canAdjustInputLevel {
                    Text(L10n.monitoringRequired)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.vertical, 4)
        } label: {
            Text(L10n.inputTitle)
        }
    }

    private var inputIconName: String {
        model.isMuted || model.inputLevel == 0 ? "mic.slash.fill" : "mic.fill"
    }
}
