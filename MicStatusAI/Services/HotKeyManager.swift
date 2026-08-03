import Carbon.HIToolbox

@MainActor
final class HotKeyManager: HotKeyManaging {
    var onPressed: (() -> Void)?

    private let registration = CarbonHotKeyRegistration()
    private let hotKeyID = EventHotKeyID(signature: OSType(0x4D53_4149), id: 1)

    init() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        var eventHandlerReference: EventHandlerRef?

        let context = Unmanaged.passUnretained(self).toOpaque()
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, context in
                guard let context else { return OSStatus(eventNotHandledErr) }
                let manager = Unmanaged<HotKeyManager>.fromOpaque(context).takeUnretainedValue()
                Task { @MainActor in
                    manager.onPressed?()
                }
                return noErr
            },
            1,
            &eventType,
            context,
            &eventHandlerReference
        )

        if status == noErr, let eventHandlerReference {
            registration.storeEventHandler(eventHandlerReference)
        }
    }

    func register(_ configuration: HotKeyConfiguration) throws {
        registration.clearHotKey()

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
        registration.replaceHotKey(with: newReference)
    }
}
