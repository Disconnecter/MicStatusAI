import Carbon.HIToolbox

final class CarbonHotKeyRegistration {
    private var hotKeyReference: EventHotKeyRef?
    private var eventHandlerReference: EventHandlerRef?

    deinit {
        clearHotKey()
        if let eventHandlerReference {
            RemoveEventHandler(eventHandlerReference)
        }
    }

    func storeEventHandler(_ reference: EventHandlerRef) {
        eventHandlerReference = reference
    }

    func replaceHotKey(with reference: EventHotKeyRef) {
        clearHotKey()
        hotKeyReference = reference
    }

    func clearHotKey() {
        guard let hotKeyReference else { return }
        UnregisterEventHotKey(hotKeyReference)
        self.hotKeyReference = nil
    }
}
