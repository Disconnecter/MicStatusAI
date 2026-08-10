@MainActor
final class NoopAnalytics: AnalyticsTracking {
    func setEnabled(_: Bool) {
        // Intentionally disabled.
    }

    func track(_: AnalyticsEvent) {
        // Intentionally disabled.
    }
}
