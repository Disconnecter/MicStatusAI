import SwiftUI

struct InputLevelControl: View {
    @Bindable var model: MicrophoneStatusModel

    var body: some View {
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
                    .frame(minWidth: 38, alignment: .trailing)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 4)
        } label: {
            Text(L10n.inputTitle)
        }
    }
}
