import AppKit
import SwiftUI

struct StatusPanelFooter: View {
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                settingsLink
                Spacer(minLength: 8)
                quitButton
            }

            VStack(alignment: .leading, spacing: 8) {
                settingsLink
                quitButton
            }
        }
    }

    private var settingsLink: some View {
        SettingsLink {
            Label {
                Text(L10n.hotkeySettings)
            } icon: {
                Image(systemName: "keyboard")
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
}
