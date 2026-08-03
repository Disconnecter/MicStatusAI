import CoreAudio
import Foundation

enum MicrophoneError: LocalizedError {
    case noDefaultInputDevice
    case volumeControlUnavailable
    case coreAudio(OSStatus)

    var errorDescription: String? {
        switch self {
        case .noDefaultInputDevice:
            String(localized: L10n.noDefaultMicrophone)
        case .volumeControlUnavailable:
            String(localized: L10n.volumeControlUnavailable)
        case let .coreAudio(status):
            String(localized: L10n.coreAudioError(status: status))
        }
    }
}
