import SwiftUI

struct MicrophoneStatusHeader: View {
    let status: MicrophoneStatus
    let isMonitoring: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: status.symbolName)
                .font(.title2)
                .foregroundStyle(status.color)
                .frame(width: 28)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(status.menuTitle)
                    .font(.headline)
                Text(isMonitoring ? L10n.monitoringActive : L10n.monitoringPaused)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
