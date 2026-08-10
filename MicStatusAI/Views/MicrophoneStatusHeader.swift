import SwiftUI

struct MicrophoneStatusHeader: View {
    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    let status: MicrophoneStatus
    let isMonitoring: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: status.symbolName)
                .font(.title2)
                .foregroundStyle(status.color)
                .frame(width: 28)
                .contentTransition(.opacity)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(status.menuTitle)
                    .font(.headline)
                    .contentTransition(.opacity)
                Text(isMonitoring ? L10n.monitoringActive : L10n.monitoringPaused)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .contentTransition(.opacity)
            }
        }
        .animation(statusAnimation, value: status)
        .animation(statusAnimation, value: isMonitoring)
        .accessibilityElement(children: .combine)
    }

    private var statusAnimation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: 0.15)
    }
}

#Preview("Active") {
    MicrophoneStatusHeader(status: .active(0.64), isMonitoring: true)
        .padding()
}

#Preview("Muted") {
    MicrophoneStatusHeader(status: .muted, isMonitoring: true)
        .padding()
}

#Preview("Monitoring Stopped") {
    MicrophoneStatusHeader(status: .stopped, isMonitoring: false)
        .padding()
}

#Preview("Unavailable") {
    MicrophoneStatusHeader(status: .unavailable("No microphone"), isMonitoring: true)
        .padding()
}
