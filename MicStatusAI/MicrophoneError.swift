import CoreAudio
import Foundation

enum MicrophoneError: LocalizedError {
    case noDefaultInputDevice
    case volumeControlUnavailable
    case coreAudio(OSStatus)

    var errorDescription: String? {
        switch self {
        case .noDefaultInputDevice:
            "No default microphone found."
        case .volumeControlUnavailable:
            "Default microphone does not expose input volume control."
        case let .coreAudio(status):
            "CoreAudio error \(status)."
        }
    }
}
