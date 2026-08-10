import Foundation

enum MicrophoneError: LocalizedError {
    case noDefaultInputDevice
    case volumeControlUnavailable
    case muteControlUnavailable
    case muteStateVerificationFailed
    case coreAudio(OSStatus)

    var analyticsCategory: String {
        switch self {
        case .noDefaultInputDevice:
            "no_default_input"
        case .volumeControlUnavailable:
            "volume_control_unavailable"
        case .muteControlUnavailable:
            "mute_control_unavailable"
        case .muteStateVerificationFailed:
            "mute_verification_failed"
        case .coreAudio:
            "core_audio"
        }
    }

    var errorDescription: String? {
        switch self {
        case .noDefaultInputDevice:
            L10n.errorNoMicrophone
        case .volumeControlUnavailable:
            L10n.errorVolumeUnavailable
        case .muteControlUnavailable:
            L10n.errorMuteUnavailable
        case .muteStateVerificationFailed:
            L10n.errorMuteVerificationFailed
        case let .coreAudio(status):
            L10n.errorCoreAudio(Int(status))
        }
    }
}
