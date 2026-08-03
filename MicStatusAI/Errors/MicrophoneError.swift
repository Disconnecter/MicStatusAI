import CoreAudio
import Foundation

enum MicrophoneError: LocalizedError {
    case noDefaultInputDevice
    case volumeControlUnavailable
    case coreAudio(OSStatus)

    var errorDescription: String? {
        switch self {
        case .noDefaultInputDevice:
            L10n.errorNoMicrophone
        case .volumeControlUnavailable:
            L10n.errorVolumeUnavailable
        case let .coreAudio(status):
            L10n.errorCoreAudio(Int(status))
        }
    }
}
