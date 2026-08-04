enum StatusOverlayPlacement: String, CaseIterable, Identifiable {
    case center
    case bottom
    case bottomLeft
    case bottomRight

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .center:
            L10n.overlayPlacementCenter
        case .bottom:
            L10n.overlayPlacementBottom
        case .bottomLeft:
            L10n.overlayPlacementBottomLeft
        case .bottomRight:
            L10n.overlayPlacementBottomRight
        }
    }
}
