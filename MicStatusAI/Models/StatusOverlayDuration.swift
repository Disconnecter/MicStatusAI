import Foundation

enum StatusOverlayDuration: Int, CaseIterable, Identifiable {
    case oneSecond = 1
    case twoSeconds = 2
    case threeSeconds = 3
    case fiveSeconds = 5

    var id: Int {
        rawValue
    }

    var seconds: TimeInterval {
        TimeInterval(rawValue)
    }

    var displayName: String {
        Duration.seconds(rawValue).formatted(
            .units(allowed: [.seconds], width: .wide)
        )
    }
}
