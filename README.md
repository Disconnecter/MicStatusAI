# MicStatusAI

Native macOS 15+ menu-bar utility showing default microphone input-volume state.

- **Red mic:** input volume is greater than zero
- **Green muted mic:** input volume is zero
- **Gray off mic:** monitoring is stopped
- **Global hotkey:** Control-Option-M by default; configurable in Settings

MicStatusAI reads and changes CoreAudio input-volume properties. It does not capture or record audio and therefore does not request microphone-recording permission.

## Build

Open `MicStatusAI.xcodeproj` in Xcode and run the `MicStatusAI` scheme.

Some microphones, including certain digital or virtual devices, do not expose software input-volume controls. MicStatusAI reports those devices as unavailable.
