# MicStatusAI

Native macOS 15+ menu-bar utility showing default microphone input-volume state.

- **Green mic:** input volume is greater than zero
- **Red muted mic:** input volume is zero
- **Gray off mic:** monitoring is stopped
- **Global hotkey:** Control-Option-M by default; configurable in Settings

MicStatusAI reads and changes CoreAudio input-volume properties. It does not capture or record audio and therefore does not request microphone-recording permission.

## Build

Install project tools and generate Xcode project:

```sh
brew install xcodegen swiftlint
xcodegen generate
```

Open `MicStatusAI.xcodeproj` in Xcode and run the `MicStatusAI` scheme. SwiftLint runs automatically during builds.

`project.yml` is project source of truth. Generated `MicStatusAI.xcodeproj` is ignored by Git.

Some microphones, including certain digital or virtual devices, do not expose software input-volume controls. MicStatusAI reports those devices as unavailable.
