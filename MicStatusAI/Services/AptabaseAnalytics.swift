@preconcurrency import Aptabase
import Foundation

@MainActor
final class AptabaseAnalytics: AnalyticsTracking {
    private let appKey: String?
    private var isEnabled: Bool
    private var isInitialized = false

    init(appKey: String?, isEnabled: Bool) {
        self.appKey = Self.validAppKey(from: appKey)
        self.isEnabled = isEnabled
        initializeIfNeeded()
    }

    func setEnabled(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
        initializeIfNeeded()
    }

    func track(_ event: AnalyticsEvent) {
        guard isEnabled else { return }
        initializeIfNeeded()
        guard isInitialized else { return }

        var properties: [String: any Value] = [:]
        for (key, property) in event.properties {
            switch property {
            case let .string(value):
                properties[key] = value
            case let .bool(value):
                properties[key] = value
            case let .int(value):
                properties[key] = value
            }
        }

        Aptabase.shared.trackEvent(event.name, with: properties)
    }

    static func configuredAppKey(bundle: Bundle = .main) -> String? {
        let bundledValue = bundle.object(forInfoDictionaryKey: "AptabaseAppKey") as? String
        if validAppKey(from: bundledValue) != nil {
            return bundledValue
        }
        return ProcessInfo.processInfo.environment["APTABASE_APP_KEY"]
    }

    private func initializeIfNeeded() {
        guard isEnabled, !isInitialized, let appKey else { return }
        Aptabase.shared.initialize(appKey: appKey)
        isInitialized = true
    }

    private static func validAppKey(from value: String?) -> String? {
        guard let value else { return nil }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: "-", maxSplits: 2)
        guard parts.count == 3, parts.first == "A" else { return nil }
        return trimmed
    }
}
