@MainActor
protocol HotKeyManaging: AnyObject {
    var onPressed: (() -> Void)? { get set }

    func register(_ configuration: HotKeyConfiguration) throws
}
