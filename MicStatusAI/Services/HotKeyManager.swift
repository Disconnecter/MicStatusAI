import Carbon.HIToolbox

@MainActor
final class HotKeyManager: HotKeyManaging {
    var onPressed: (() -> Void)?

    nonisolated(unsafe) private var hotKeyReference: EventHotKeyRef?
    nonisolated(unsafe) private var eventHandlerReference: EventHandlerRef?
    private let hotKeyID = EventHotKeyID(signature: OSType(0x4D53_4149), id: 1)

    init() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let context = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, context in
                guard let context else { return OSStatus(eventNotHandledErr) }
                let manager = Unmanaged<HotKeyManager>.fromOpaque(context).takeUnretainedValue()
                MainActor.assumeIsolated {
                    manager.onPressed?()
                }
                return noErr
            },
            1,
            &eventType,
            context,
            &eventHandlerReference
        )
    }

    deinit {
        if let hotKeyReference {
            UnregisterEventHotKey(hotKeyReference)
        }
        if let eventHandlerReference {
            RemoveEventHandler(eventHandlerReference)
        }
    }

    func register(_ configuration: HotKeyConfiguration) throws {
        if let hotKeyReference {
            UnregisterEventHotKey(hotKeyReference)
            self.hotKeyReference = nil
        }

        guard configuration.modifierCount >= 2 else {
            throw HotKeyError.twoModifiersRequired
        }

        var newReference: EventHotKeyRef?
        let status = RegisterEventHotKey(
            configuration.keyCode,
            configuration.carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &newReference
        )
        guard status == noErr, let newReference else {
            throw HotKeyError.registrationFailed(status)
        }
        hotKeyReference = newReference
    }
}
