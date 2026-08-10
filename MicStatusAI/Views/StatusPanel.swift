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
                MicrophoneErrorView(
                    message: message,
                    onRetry: model.retryMonitoring
                )
            }

            InputLevelControl(model: model)
            MicrophoneActionsView(model: model)

            Divider()

            StatusPanelFooter()
        }
        .padding(14)
        .frame(minWidth: 300, idealWidth: 330, maxWidth: 360)
    }
}
