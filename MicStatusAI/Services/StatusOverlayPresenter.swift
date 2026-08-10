import AppKit
import SwiftUI

@MainActor
final class StatusOverlayPresenter {
    private let edgeInset: CGFloat = 48
    private let fadeDuration = 0.15
    private var dismissalTask: Task<Void, Never>?
    private var panel: NSPanel?

    func dismiss() {
        dismissalTask?.cancel()
        dismissalTask = nil
        panel?.orderOut(nil)
    }

    func show(
        status: MicrophoneStatus,
        duration: TimeInterval,
        placement: StatusOverlayPlacement,
        transparency: Double
    ) {
        dismissalTask?.cancel()

        let currentPanel = panel ?? makePanel()
        let overlayView = StatusOverlayView(status: status)
        let visibleAlpha = CGFloat(
            StatusOverlayTransparency.overlayOpacity(for: transparency)
        )
        let hostingView = NSHostingView(rootView: overlayView)
        hostingView.layoutSubtreeIfNeeded()

        currentPanel.contentView = hostingView
        currentPanel.setContentSize(hostingView.fittingSize)
        position(currentPanel, at: placement)
        currentPanel.alphaValue = 0
        currentPanel.orderFrontRegardless()

        animateAlpha(visibleAlpha, for: currentPanel)

        announce(status.accessibilityLabel)
        scheduleDismissal(after: duration)
    }

    private func makePanel() -> NSPanel {
        let newPanel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        newPanel.isFloatingPanel = true
        newPanel.level = .floating
        newPanel.isOpaque = false
        newPanel.backgroundColor = .clear
        newPanel.hasShadow = true
        newPanel.hidesOnDeactivate = false
        newPanel.isReleasedWhenClosed = false
        newPanel.ignoresMouseEvents = true
        newPanel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .ignoresCycle,
            .transient,
        ]
        panel = newPanel
        return newPanel
    }

    private func position(
        _ panel: NSPanel,
        at placement: StatusOverlayPlacement
    ) {
        guard let screen = NSScreen.main ?? NSScreen.screens.first else { return }

        let screenFrame = screen.visibleFrame
        let panelSize = panel.frame.size
        let centeredX = screenFrame.midX - (panelSize.width / 2)
        let bottomY = screenFrame.minY + edgeInset

        let origin = switch placement {
        case .center:
            NSPoint(
                x: centeredX,
                y: screenFrame.midY - (panelSize.height / 2)
            )
        case .bottom:
            NSPoint(x: centeredX, y: bottomY)
        case .bottomLeft:
            NSPoint(x: screenFrame.minX + edgeInset, y: bottomY)
        case .bottomRight:
            NSPoint(
                x: screenFrame.maxX - panelSize.width - edgeInset,
                y: bottomY
            )
        }

        panel.setFrameOrigin(origin)
    }

    private func announce(_ message: String) {
        NSAccessibility.post(
            element: NSApplication.shared,
            notification: .announcementRequested,
            userInfo: [
                .announcement: message,
                .priority: NSAccessibilityPriorityLevel.medium.rawValue,
            ]
        )
    }

    private func animateAlpha(_ alpha: CGFloat, for panel: NSPanel) {
        let duration = animationDuration
        guard duration > 0 else {
            panel.alphaValue = alpha
            return
        }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            panel.animator().alphaValue = alpha
        }
    }

    private func fadeOut() {
        guard let panel else { return }
        animateAlpha(0, for: panel)
    }

    private var animationDuration: TimeInterval {
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion ? 0 : fadeDuration
    }

    private func scheduleDismissal(after duration: TimeInterval) {
        dismissalTask = Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                try await Task.sleep(for: .seconds(duration))
            } catch {
                return
            }

            let fadeOutDuration = animationDuration
            fadeOut()

            if fadeOutDuration > 0 {
                do {
                    try await Task.sleep(for: .seconds(fadeOutDuration))
                } catch {
                    return
                }
            }

            guard !Task.isCancelled else { return }
            panel?.orderOut(nil)
        }
    }
}
