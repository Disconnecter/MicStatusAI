import SwiftUI

struct StatusOverlaySettingsView: View {
    @Binding var isEnabled: Bool
    @Binding var duration: StatusOverlayDuration
    @Binding var placement: StatusOverlayPlacement
    @Binding var transparency: Double
    let analytics: any AnalyticsTracking
    let onShowPreview: () -> Void

    var body: some View {
        Section {
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

            ViewThatFits(in: .horizontal) {
                LabeledContent {
                    transparencyControl
                } label: {
                    Text(L10n.overlayTransparency)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.overlayTransparency)
                    transparencyControl
                }
            }
            .disabled(!isEnabled)

            Button(action: onShowPreview) {
                Label {
                    Text(L10n.overlayPreview)
                } icon: {
                    Image(systemName: "play.display")
                }
            }
        } header: {
            Text(L10n.overlayTitle)
        } footer: {
            Text(L10n.overlayHelp)
        }
        .onChange(of: isEnabled) { _, newValue in
            analytics.track(.overlayEnabledChanged(enabled: newValue))
        }
        .onChange(of: duration) { _, newValue in
            analytics.track(.overlayDurationChanged(seconds: newValue.rawValue))
        }
        .onChange(of: placement) { _, newValue in
            analytics.track(.overlayPlacementChanged(placement: newValue.rawValue))
        }
    }

    private var transparencyControl: some View {
        HStack(spacing: 8) {
            Slider(
                value: $transparency,
                in: StatusOverlayTransparency.range,
                step: StatusOverlayTransparency.step,
                onEditingChanged: { isEditing in
                    guard !isEditing else { return }
                    let percentBucket = Int((transparency * 4).rounded()) * 25
                    analytics.track(
                        .overlayTransparencyChanged(percentBucket: percentBucket)
                    )
                },
                label: {
                    Text(L10n.overlayTransparency)
                }
            )
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
    }
}

#Preview("Narrow Overlay Settings", traits: .fixedLayout(width: 340, height: 360)) {
    @Previewable @State var isEnabled = true
    @Previewable @State var duration = StatusOverlayDuration.oneSecond
    @Previewable @State var placement = StatusOverlayPlacement.center
    @Previewable @State var transparency = StatusOverlayTransparency.defaultValue

    Form {
        StatusOverlaySettingsView(
            isEnabled: $isEnabled,
            duration: $duration,
            placement: $placement,
            transparency: $transparency,
            analytics: NoopAnalytics()
        ) {
            // Preview action
        }
    }
    .formStyle(.grouped)
}
