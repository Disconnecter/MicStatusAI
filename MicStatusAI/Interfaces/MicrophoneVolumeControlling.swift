protocol MicrophoneVolumeControlling {
    func inputVolume() throws -> Float32
    func setInputVolume(_ volume: Float32) throws
}
