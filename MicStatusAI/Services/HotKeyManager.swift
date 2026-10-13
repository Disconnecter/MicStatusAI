import Carbon.HIToolbox

@MainActor
final class HotKeyManager: HotKeyManaging {
    var onPressed: (() -> Void)?
    var onReleased: (() -> Void)?

    private let registration = CarbonHotKeyRegistration()
    nonisolated private let hotKeyID: EventHotKeyID

    init(id: UInt32 = 1) {
        hotKeyID = EventHotKeyID(signature: OSType(0x4D53_4149), id: id)

        var eventTypes = [
            EventTypeSpec(
                eventClass: OSType(kEventClassKeyboard),
                eventKind: UInt32(kEventHotKeyPressed)
            ),
            EventTypeSpec(
                eventClass: OSType(kEventClassKeyboard),
                eventKind: UInt32(kEventHotKeyReleased)
            ),
        ]
        var eventHandlerReference: EventHandlerRef?

        let context = Unmanaged.passUnretained(self).toOpaque()
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, context in
                guard let event, let context else { return OSStatus(eventNotHandledErr) }
                let manager = Unmanaged<HotKeyManager>.fromOpaque(context).takeUnretainedValue()
                var receivedHotKeyID = EventHotKeyID()
                let parameterStatus = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &receivedHotKeyID
                )
                guard parameterStatus == noErr else { return parameterStatus }
                guard receivedHotKeyID.signature == manager.hotKeyID.signature,
                      receivedHotKeyID.id == manager.hotKeyID.id else {
                    return OSStatus(eventNotHandledErr)
                }

                let eventKind = GetEventKind(event)
                Task { @MainActor in
                    switch eventKind {
                    case UInt32(kEventHotKeyPressed):
                        manager.onPressed?()
                    case UInt32(kEventHotKeyReleased):
                        manager.onReleased?()
                    default:
                        break
                    }
                }
                return noErr
            },
            eventTypes.count,
            &eventTypes,
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
