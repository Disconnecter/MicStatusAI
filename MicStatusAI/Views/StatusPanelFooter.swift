import AppKit
import SwiftUI

struct StatusPanelFooter: View {
    @Environment(\.openSettings)
    private var openSettings

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                settingsButton
                Spacer(minLength: 8)
                quitButton
            }

            VStack(alignment: .leading, spacing: 8) {
                settingsButton
                quitButton
            }
        }
    }

    private var settingsButton: some View {
        Button(action: showSettings) {
            Label {
                Text(L10n.settingsOpen)
            } icon: {
                Image(systemName: "gearshape")
            }
        }
    }

    private var quitButton: some View {
        Button {
            NSApplication.shared.terminate(nil)
        } label: {
            Text(L10n.actionQuit)
        }
        .keyboardShortcut("q")
    }

    private func showSettings() {
        NSApplication.shared.activate()
        openSettings()
    }
}
