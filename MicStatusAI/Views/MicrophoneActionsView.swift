import SwiftUI

struct MicrophoneActionsView: View {
    let model: MicrophoneStatusModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle(L10n.monitoringEnabled, isOn: monitoringBinding)
                .toggleStyle(.switch)

            Toggle(isOn: walkieTalkieBinding) {
                Label(L10n.walkieTalkieEnabled, systemImage: "walkie.talkie")
            }
            .toggleStyle(.switch)
            .disabled(model.walkieTalkieHotKeyRegistrationError != nil)
            .help(model.walkieTalkieHotKeyRegistrationError ?? L10n.walkieTalkieInstructions)

            Button {
                model.toggleMute(source: .button)
            } label: {
                Label {
                    Text(model.isMuted ? L10n.actionUnmute : L10n.actionMute)
                } icon: {
                    Image(systemName: model.isMuted ? "mic.fill" : "mic.slash.fill")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(
                !model.isMonitoring
                    || model.status.errorMessage != nil
                    || model.isWalkieTalkieEnabled
            )
            .help(
                model.isWalkieTalkieEnabled
                    ? L10n.walkieTalkieMuteHelp
                    : L10n.actionMuteHelp
            )
        }
    }

    private var walkieTalkieBinding: Binding<Bool> {
        Binding(
            get: { model.isWalkieTalkieEnabled },
            set: { model.setWalkieTalkieEnabled($0) }
        )
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
