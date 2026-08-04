enum StatusOverlayTransparency {
    static let defaultValue = 0.3
    static let range = 0.0 ... 0.8
    static let step = 0.05

    static func overlayOpacity(for transparency: Double) -> Double {
        let clampedValue = min(
            max(transparency, range.lowerBound),
            range.upperBound
        )
        return 1 - clampedValue
    }
}
