protocol MicrophoneVolumeControlling {
    func defaultInputDeviceID() throws -> UInt32
    func inputVolume(for deviceID: UInt32) throws -> Float32
    func setInputVolume(_ volume: Float32, for deviceID: UInt32) throws
    func isMuted(for deviceID: UInt32) throws -> Bool
    func setMuted(_ muted: Bool, for deviceID: UInt32) throws
}
