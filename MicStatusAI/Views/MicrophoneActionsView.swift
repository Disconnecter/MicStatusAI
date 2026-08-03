import SwiftUI

struct MicrophoneActionsView: View {
    let model: MicrophoneStatusModel

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                monitoringButton
                Spacer(minLength: 8)
                muteButton
            }

            VStack(alignment: .leading, spacing: 8) {
                monitoringButton
                muteButton
            }
        }
    }

    private var monitoringButton: some View {
        Button {
            model.toggleMonitoring()
        } label: {
            Text(model.isMonitoring ? L10n.actionStop : L10n.actionStart)
        }
    }

    private var muteButton: some View {
        Button {
            model.toggleMute()
        } label: {
            Text(model.isMuted ? L10n.actionUnmute : L10n.actionMute)
        }
        .disabled(model.status.errorMessage != nil)
    }
}
