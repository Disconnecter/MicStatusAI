import CoreAudio
import Foundation

struct CoreAudioMicrophone {
    func inputVolume() throws -> Float32 {
        let deviceID = try defaultInputDeviceID()
        let addresses = volumeAddresses(for: deviceID)
        guard !addresses.isEmpty else {
            throw MicrophoneError.volumeControlUnavailable
        }

        let volumes = try addresses.map { try readVolume(deviceID: deviceID, address: $0) }
        return volumes.max() ?? 0
    }

    func setInputVolume(_ volume: Float32) throws {
        let deviceID = try defaultInputDeviceID()
        let clampedVolume = min(max(volume, 0), 1)
        let addresses = writableVolumeAddresses(for: deviceID)
        guard !addresses.isEmpty else {
            throw MicrophoneError.volumeControlUnavailable
        }

        for var address in addresses {
            var value = clampedVolume
            let status = AudioObjectSetPropertyData(
                deviceID,
                &address,
                0,
                nil,
                UInt32(MemoryLayout<Float32>.size),
                &value
            )
            guard status == noErr else {
                throw MicrophoneError.coreAudio(status)
            }
        }
    }

    private func defaultInputDeviceID() throws -> AudioDeviceID {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var deviceID = AudioDeviceID(kAudioObjectUnknown)
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)

        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &size,
            &deviceID
        )
        guard status == noErr else {
            throw MicrophoneError.coreAudio(status)
        }
        guard deviceID != kAudioObjectUnknown else {
            throw MicrophoneError.noDefaultInputDevice
        }
        return deviceID
    }

    private func volumeAddresses(for deviceID: AudioDeviceID) -> [AudioObjectPropertyAddress] {
        let masterAddress = makeVolumeAddress(element: kAudioObjectPropertyElementMain)
        if hasProperty(deviceID: deviceID, address: masterAddress) {
            return [masterAddress]
        }

        return (1 ... 32).compactMap { channel in
            let address = makeVolumeAddress(element: AudioObjectPropertyElement(channel))
            return hasProperty(deviceID: deviceID, address: address) ? address : nil
        }
    }

    private func writableVolumeAddresses(for deviceID: AudioDeviceID) -> [AudioObjectPropertyAddress] {
        volumeAddresses(for: deviceID).filter { address in
            var mutableAddress = address
            var isSettable = DarwinBoolean(false)
            let status = AudioObjectIsPropertySettable(deviceID, &mutableAddress, &isSettable)
            return status == noErr && isSettable.boolValue
        }
    }

    private func makeVolumeAddress(element: AudioObjectPropertyElement) -> AudioObjectPropertyAddress {
        AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: element
        )
    }

    private func hasProperty(
        deviceID: AudioDeviceID,
        address: AudioObjectPropertyAddress
    ) -> Bool {
        var mutableAddress = address
        return AudioObjectHasProperty(deviceID, &mutableAddress)
    }

    private func readVolume(
        deviceID: AudioDeviceID,
        address: AudioObjectPropertyAddress
    ) throws -> Float32 {
        var mutableAddress = address
        var volume: Float32 = 0
        var size = UInt32(MemoryLayout<Float32>.size)
        let status = AudioObjectGetPropertyData(
            deviceID,
            &mutableAddress,
            0,
            nil,
            &size,
            &volume
        )
        guard status == noErr else {
            throw MicrophoneError.coreAudio(status)
        }
        return volume
    }
}

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
