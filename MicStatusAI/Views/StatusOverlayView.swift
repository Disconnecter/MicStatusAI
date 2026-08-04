import SwiftUI

struct StatusOverlayView: View {
    @ScaledMetric(relativeTo: .largeTitle)
    private var iconSize = 42.0

    let status: MicrophoneStatus

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: status.symbolName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(status.color)
                .accessibilityHidden(true)

            Text(status.menuTitle)
                .font(.headline)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(minWidth: 180, maxWidth: 280, minHeight: 132)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(.separator.opacity(0.25))
        }
        .accessibilityElement(children: .combine)
    }
}
