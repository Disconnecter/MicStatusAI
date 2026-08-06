// swiftlint:disable all
// Generated from Localizable.xcstrings
// Do not edit manually

import Foundation

public enum L10n {
  /// Mute
  public static var actionMute: String {
    return tr(key: "action.mute")
  }

  /// Quit
  public static var actionQuit: String {
    return tr(key: "action.quit")
  }

  /// Restore Default
  public static var actionRestoreHotkey: String {
    return tr(key: "action.restoreHotkey")
  }

  /// Start Monitoring
  public static var actionStart: String {
    return tr(key: "action.start")
  }

  /// Stop Monitoring
  public static var actionStop: String {
    return tr(key: "action.stop")
  }

  /// Unmute
  public static var actionUnmute: String {
    return tr(key: "action.unmute")
  }

  /// CoreAudio error %d.
  public static func errorCoreAudio(_ p1: Int) -> String {
    return tr(key: "error.coreAudio", p1)
  }

  /// Could not register hotkey (error %d). Another app may use it.
  public static func errorHotkeyRegistration(_ p1: Int) -> String {
    return tr(key: "error.hotkeyRegistration", p1)
  }

  /// Shortcut needs at least two modifier keys and one letter or number.
  public static var errorInvalidHotkey: String {
    return tr(key: "error.invalidHotkey")
  }

  /// Default microphone does not expose input mute control.
  public static var errorMuteUnavailable: String {
    return tr(key: "error.muteUnavailable")
  }

  /// Default microphone did not confirm the requested mute state.
  public static var errorMuteVerificationFailed: String {
    return tr(key: "error.muteVerificationFailed")
  }

  /// No default microphone found.
  public static var errorNoMicrophone: String {
    return tr(key: "error.noMicrophone")
  }

  /// Default microphone does not expose input volume control.
  public static var errorVolumeUnavailable: String {
    return tr(key: "error.volumeUnavailable")
  }

  /// Mute and unmute shortcut
  public static var hotkeyAccessibility: String {
    return tr(key: "hotkey.accessibility")
  }

  /// %@ active system-wide
  public static func hotkeyActive(_ p1: String) -> String {
    return tr(key: "hotkey.active", p1)
  }

  /// Press Escape to cancel
  public static var hotkeyCancel: String {
    return tr(key: "hotkey.cancel")
  }

  /// Press Escape while recording to cancel.
  public static var hotkeyCancelHelp: String {
    return tr(key: "hotkey.cancelHelp")
  }

  /// Click shortcut field, then press new combination. Shortcut must contain at least two modifier keys and one letter or number.
  public static var hotkeyInstructions: String {
    return tr(key: "hotkey.instructions")
  }

  /// Keyboard Shortcut
  public static var hotkeyLabel: String {
    return tr(key: "hotkey.label")
  }

  /// Press shortcut…
  public static var hotkeyPrompt: String {
    return tr(key: "hotkey.prompt")
  }

  /// Recording. Press at least two modifiers and one letter or number.
  public static var hotkeyRecording: String {
    return tr(key: "hotkey.recording")
  }

  /// Mute / Unmute Hotkey
  public static var hotkeyTitle: String {
    return tr(key: "hotkey.title")
  }

  /// Click, then press a new shortcut
  public static var hotkeyTooltip: String {
    return tr(key: "hotkey.tooltip")
  }

  /// Microphone input level
  public static var inputAccessibility: String {
    return tr(key: "input.accessibility")
  }

  /// Input Level
  public static var inputTitle: String {
    return tr(key: "input.title")
  }

  /// Monitoring default microphone
  public static var monitoringActive: String {
    return tr(key: "monitoring.active")
  }

  /// Monitoring Off
  public static var monitoringOff: String {
    return tr(key: "monitoring.off")
  }

  /// Monitoring paused
  public static var monitoringPaused: String {
    return tr(key: "monitoring.paused")
  }

  /// Display Duration
  public static var overlayDuration: String {
    return tr(key: "overlay.duration")
  }

  /// Show Status Overlay
  public static var overlayEnabled: String {
    return tr(key: "overlay.enabled")
  }

  /// Shown when microphone is muted or unmuted.
  public static var overlayHelp: String {
    return tr(key: "overlay.help")
  }

  /// Placement
  public static var overlayPlacement: String {
    return tr(key: "overlay.placement")
  }

  /// Bottom
  public static var overlayPlacementBottom: String {
    return tr(key: "overlay.placement.bottom")
  }

  /// Bottom Left
  public static var overlayPlacementBottomLeft: String {
    return tr(key: "overlay.placement.bottomLeft")
  }

  /// Bottom Right
  public static var overlayPlacementBottomRight: String {
    return tr(key: "overlay.placement.bottomRight")
  }

  /// Center
  public static var overlayPlacementCenter: String {
    return tr(key: "overlay.placement.center")
  }

  /// Status Overlay
  public static var overlayTitle: String {
    return tr(key: "overlay.title")
  }

  /// Transparency
  public static var overlayTransparency: String {
    return tr(key: "overlay.transparency")
  }

  /// Settings…
  public static var settingsOpen: String {
    return tr(key: "settings.open")
  }

  /// MicStatusAI Settings
  public static var settingsTitle: String {
    return tr(key: "settings.title")
  }

  /// Microphone Muted
  public static var statusMuted: String {
    return tr(key: "status.muted")
  }

  /// Microphone On · %@
  public static func statusOn(_ p1: String) -> String {
    return tr(key: "status.on", p1)
  }

  /// Microphone Unavailable
  public static var statusUnavailable: String {
    return tr(key: "status.unavailable")
  }

  /// Use a letter or number as shortcut key.
  public static var validationKey: String {
    return tr(key: "validation.key")
  }

  /// Press at least two modifier keys plus one letter or number.
  public static var validationModifiers: String {
    return tr(key: "validation.modifiers")
  }

  private static func tr(key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(
      key,
      tableName: "Localizable",
      bundle: Bundle.main,
      value: "",
      comment: key
    )
    return String.localizedStringWithFormat(format, args)
  }
}
