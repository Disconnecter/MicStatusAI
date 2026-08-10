import SwiftUI

struct MicrophoneActionsView: View {
    let model: MicrophoneStatusModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle(L10n.monitoringEnabled, isOn: monitoringBinding)
                .toggleStyle(.switch)

            Button(action: model.toggleMute) {
                Label {
                    Text(model.isMuted ? L10n.actionUnmute : L10n.actionMute)
                } icon: {
                    Image(systemName: model.isMuted ? "mic.fill" : "mic.slash.fill")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!model.isMonitoring || model.status.errorMessage != nil)
            .help(L10n.actionMuteHelp)
        }
    }

    private var monitoringBinding: Binding<Bool> {
        Binding(
            get: { model.isMonitoring },
            set: { shouldMonitor in
                guard shouldMonitor != model.isMonitoring else { return }
                model.toggleMonitoring()
            }
        )
    }
}
