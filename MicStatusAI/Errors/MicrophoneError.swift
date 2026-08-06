import Foundation

enum MicrophoneError: LocalizedError {
    case noDefaultInputDevice
    case volumeControlUnavailable
    case muteControlUnavailable
    case muteStateVerificationFailed
    case coreAudio(OSStatus)

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
