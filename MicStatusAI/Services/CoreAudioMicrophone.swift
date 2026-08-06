import CoreAudio

struct CoreAudioMicrophone: MicrophoneVolumeControlling {
    func inputVolume(for deviceID: UInt32) throws -> Float32 {
        let addresses = volumeAddresses(for: deviceID)
        guard !addresses.isEmpty else {
            throw MicrophoneError.volumeControlUnavailable
        }

        let volumes = try addresses.map { try readVolume(deviceID: deviceID, address: $0) }
        return volumes.max() ?? 0
    }

    func setInputVolume(_ volume: Float32, for deviceID: UInt32) throws {
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

    func isMuted(for deviceID: UInt32) throws -> Bool {
        let addresses = muteAddresses(for: deviceID)
        guard !addresses.isEmpty else {
            throw MicrophoneError.muteControlUnavailable
        }

        return try addresses.allSatisfy {
            try readMute(deviceID: deviceID, address: $0)
        }
    }

    func setMuted(_ muted: Bool, for deviceID: UInt32) throws {
        let addresses = writableMuteAddresses(for: deviceID)
        guard !addresses.isEmpty else {
            throw MicrophoneError.muteControlUnavailable
        }

        for var address in addresses {
            var value: UInt32 = muted ? 1 : 0
            let status = AudioObjectSetPropertyData(
                deviceID,
                &address,
                0,
                nil,
                UInt32(MemoryLayout<UInt32>.size),
                &value
            )
            guard status == noErr else {
                throw MicrophoneError.coreAudio(status)
            }
        }

        let verified = try addresses.allSatisfy {
            try readMute(deviceID: deviceID, address: $0) == muted
        }
        guard verified else {
            throw MicrophoneError.muteStateVerificationFailed
        }
    }

    func defaultInputDeviceID() throws -> UInt32 {
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
        let mainElementAddress = makeVolumeAddress(element: kAudioObjectPropertyElementMain)
        if hasProperty(deviceID: deviceID, address: mainElementAddress) {
            return [mainElementAddress]
        }

        return (1 ... 32).compactMap { channel in
            let address = makeVolumeAddress(element: AudioObjectPropertyElement(channel))
            return hasProperty(deviceID: deviceID, address: address) ? address : nil
        }
    }

    private func writableVolumeAddresses(for deviceID: AudioDeviceID) -> [AudioObjectPropertyAddress] {
        volumeAddresses(for: deviceID).filter {
            isPropertySettable(deviceID: deviceID, address: $0)
        }
    }

    private func muteAddresses(for deviceID: AudioDeviceID) -> [AudioObjectPropertyAddress] {
        let mainElementAddress = makeMuteAddress(element: kAudioObjectPropertyElementMain)
        if hasProperty(deviceID: deviceID, address: mainElementAddress) {
            return [mainElementAddress]
        }

        return (1 ... 32).compactMap { channel in
            let address = makeMuteAddress(element: AudioObjectPropertyElement(channel))
            return hasProperty(deviceID: deviceID, address: address) ? address : nil
        }
    }

    private func writableMuteAddresses(for deviceID: AudioDeviceID) -> [AudioObjectPropertyAddress] {
        muteAddresses(for: deviceID).filter {
            isPropertySettable(deviceID: deviceID, address: $0)
        }
    }

    private func makeVolumeAddress(element: AudioObjectPropertyElement) -> AudioObjectPropertyAddress {
        AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: element
        )
    }

    private func makeMuteAddress(element: AudioObjectPropertyElement) -> AudioObjectPropertyAddress {
        AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
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

    private func isPropertySettable(
        deviceID: AudioDeviceID,
        address: AudioObjectPropertyAddress
    ) -> Bool {
        var mutableAddress = address
        var isSettable = DarwinBoolean(false)
        let status = AudioObjectIsPropertySettable(deviceID, &mutableAddress, &isSettable)
        return status == noErr && isSettable.boolValue
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

    private func readMute(
        deviceID: AudioDeviceID,
        address: AudioObjectPropertyAddress
    ) throws -> Bool {
        var mutableAddress = address
        var muted: UInt32 = 0
        var size = UInt32(MemoryLayout<UInt32>.size)
        let status = AudioObjectGetPropertyData(
            deviceID,
            &mutableAddress,
            0,
            nil,
            &size,
            &muted
        )
        guard status == noErr else {
            throw MicrophoneError.coreAudio(status)
        }
        return muted != 0
    }
}
