@MainActor
protocol AnalyticsTracking: AnyObject {
    func setEnabled(_ isEnabled: Bool)
    func track(_ event: AnalyticsEvent)
}
