import SwiftUI

struct StatusPanel: View {
    let model: MicrophoneStatusModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            MicrophoneStatusHeader(
                status: model.status,
                isMonitoring: model.isMonitoring
            )

            if let message = model.status.errorMessage {
                Label(message, systemImage: "exclamationmark.triangle.fill")
                    .font(.callout)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }

            InputLevelControl(model: model)
            MicrophoneActionsView(model: model)

            Divider()

            StatusPanelFooter()
        }
        .padding(14)
        .frame(width: 330)
    }
}
