import Foundation

enum L10n {
    static let monitoringDefaultMicrophone = LocalizedStringResource(
        "Monitoring default microphone",
        comment: "Status shown while monitoring the default microphone."
    )

    static let monitoringPaused = LocalizedStringResource(
        "Monitoring paused",
        comment: "Status shown when microphone monitoring is paused."
    )

    static let microphoneMuted = LocalizedStringResource(
        "Microphone Muted",
        comment: "Primary status shown when microphone input volume is zero."
    )

    static let monitoringOff = LocalizedStringResource(
        "Monitoring Off",
        comment: "Primary status shown when microphone monitoring is disabled."
    )

    static let microphoneUnavailable = LocalizedStringResource(
        "Microphone Unavailable",
        comment: "Primary status shown when microphone input cannot be accessed."
    )

    static let inputLevel = LocalizedStringResource(
        "Input Level",
        comment: "Heading for microphone input volume controls."
    )

    static let microphoneInputLevel = LocalizedStringResource(
        "Microphone input level",
        comment: "Accessibility label for the microphone input volume slider."
    )

    static let stopMonitoring = LocalizedStringResource(
        "Stop Monitoring",
        comment: "Button that stops microphone input monitoring."
    )

    static let startMonitoring = LocalizedStringResource(
        "Start Monitoring",
        comment: "Button that starts microphone input monitoring."
    )

    static let unmute = LocalizedStringResource(
        "Unmute",
        comment: "Button that restores microphone input volume."
    )

    static let mute = LocalizedStringResource(
        "Mute",
        comment: "Button that sets microphone input volume to zero."
    )

    static let hotKeySettings = LocalizedStringResource(
        "Hotkey Settings…",
        comment: "Button that opens global hotkey settings."
    )

    static let quit = LocalizedStringResource(
        "Quit",
        comment: "Button that quits the application."
    )

    static let noDefaultMicrophone = LocalizedStringResource(
        "No default microphone found.",
        comment: "Error shown when macOS has no default microphone."
    )

    static let volumeControlUnavailable = LocalizedStringResource(
        "Default microphone does not expose input volume control.",
        comment: "Error shown when the default microphone has no software volume control."
    )

    static let shortcutNeedsTwoModifiers = LocalizedStringResource(
        "Shortcut needs at least two modifier keys and one letter or number.",
        comment: "Error shown when a global hotkey does not have enough modifier keys."
    )

    static let pressTwoModifiers = LocalizedStringResource(
        "Press at least two modifier keys plus one letter or number.",
        comment: "Validation error shown while recording an incomplete global hotkey."
    )

    static let useLetterOrNumber = LocalizedStringResource(
        "Use a letter or number as shortcut key.",
        comment: "Validation error shown when a global hotkey uses an unsupported key."
    )

    static let shortcutToolTip = LocalizedStringResource(
        "Click, then press a new shortcut",
        comment: "Tooltip for the global hotkey recorder."
    )

    static let shortcutAccessibilityLabel = LocalizedStringResource(
        "Mute and unmute shortcut",
        comment: "Accessibility label for the global hotkey recorder."
    )

    static let pressShortcut = LocalizedStringResource(
        "Press shortcut…",
        comment: "Global hotkey recorder title while waiting for keyboard input."
    )

    static let pressEscapeToCancel = LocalizedStringResource(
        "Press Escape to cancel",
        comment: "Tooltip shown while recording a global hotkey."
    )

    static let recordingAccessibilityValue = LocalizedStringResource(
        "Recording. Press at least two modifiers and one letter or number.",
        comment: "Accessibility value announced while recording a global hotkey."
    )

    static let muteUnmuteHotKey = LocalizedStringResource(
        "Mute / Unmute Hotkey",
        comment: "Heading for global hotkey settings."
    )

    static let shortcutInstructions = LocalizedStringResource(
        """
        Click shortcut field, then press new combination. \
        Shortcut must contain at least two modifier keys and one letter or number.
        """,
        comment: "Instructions for configuring the global hotkey."
    )

    static let keyboardShortcut = LocalizedStringResource(
        "Keyboard Shortcut",
        comment: "Label for the configured global hotkey."
    )

    static let pressEscapeWhileRecording = LocalizedStringResource(
        "Press Escape while recording to cancel.",
        comment: "Help text below the global hotkey recorder."
    )

    static let restoreDefault = LocalizedStringResource(
        "Restore Default",
        comment: "Button that restores the default global hotkey."
    )

    static func microphoneOn(percentage: Int) -> LocalizedStringResource {
        LocalizedStringResource(
            "Microphone On · \(percentage)%",
            comment: "Primary microphone status. Argument is the current input volume percentage."
        )
    }

    static func coreAudioError(status: Int32) -> LocalizedStringResource {
        LocalizedStringResource(
            "CoreAudio error \(status).",
            comment: "Microphone error. Argument is a CoreAudio status code."
        )
    }

    static func hotKeyRegistrationFailed(status: Int32) -> LocalizedStringResource {
        LocalizedStringResource(
            "Could not register hotkey (error \(status)). Another app may use it.",
            comment: "Global hotkey error. Argument is a Carbon status code."
        )
    }

    static func hotKeyActive(displayName: String) -> LocalizedStringResource {
        LocalizedStringResource(
            "\(displayName) active system-wide",
            comment: "Global hotkey status. Argument is the configured keyboard shortcut."
        )
    }
}
