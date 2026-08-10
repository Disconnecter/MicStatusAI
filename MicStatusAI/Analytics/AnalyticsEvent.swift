struct AnalyticsEvent {
    enum Property {
        case string(String)
        case bool(Bool)
        case int(Int)
    }

    enum MuteSource: String {
        case button
        case hotKey = "hotkey"
    }

    enum MicrophoneOperation: String {
        case monitoring
        case mute
        case inputLevel = "input_level"
    }

    let name: String
    let properties: [String: Property]

    static let appLaunched = Self(name: "app_launched")
    static let settingsOpened = Self(name: "settings_opened")
    static let analyticsEnabled = Self(name: "analytics_enabled")
    static let overlayPreviewed = Self(name: "overlay_previewed")
    static let overlayShown = Self(name: "overlay_shown")

    static func monitoringChanged(enabled: Bool) -> Self {
        Self(
            name: "monitoring_changed",
            properties: ["enabled": .bool(enabled)]
        )
    }

    static func muteChanged(isMuted: Bool, source: MuteSource) -> Self {
        Self(
            name: "mute_changed",
            properties: [
                "is_muted": .bool(isMuted),
                "source": .string(source.rawValue),
            ]
        )
    }

    static func inputLevelChanged(percentBucket: Int) -> Self {
        Self(
            name: "input_level_changed",
            properties: ["percent_bucket": .int(percentBucket)]
        )
    }

    static func overlayEnabledChanged(enabled: Bool) -> Self {
        Self(
            name: "overlay_enabled_changed",
            properties: ["enabled": .bool(enabled)]
        )
    }

    static func overlayDurationChanged(seconds: Int) -> Self {
        Self(
            name: "overlay_duration_changed",
            properties: ["seconds": .int(seconds)]
        )
    }

    static func overlayPlacementChanged(placement: String) -> Self {
        Self(
            name: "overlay_placement_changed",
            properties: ["placement": .string(placement)]
        )
    }

    static func overlayTransparencyChanged(percentBucket: Int) -> Self {
        Self(
            name: "overlay_transparency_changed",
            properties: ["percent_bucket": .int(percentBucket)]
        )
    }

    static func hotKeyChanged(success: Bool) -> Self {
        Self(
            name: "hotkey_changed",
            properties: ["success": .bool(success)]
        )
    }

    static func microphoneError(
        operation: MicrophoneOperation,
        category: String
    ) -> Self {
        Self(
            name: "microphone_error",
            properties: [
                "operation": .string(operation.rawValue),
                "category": .string(category),
            ]
        )
    }

    private init(name: String, properties: [String: Property] = [:]) {
        self.name = name
        self.properties = properties
    }
}
