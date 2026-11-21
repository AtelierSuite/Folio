import Foundation

/// Holds a coordinated write on a file or folder on its own thread, as another process syncing it would.
final class HeldFileCoordination: @unchecked Sendable {
    private let acquired = DispatchSemaphore(value: 0)
    private let released = DispatchSemaphore(value: 0)
    private let lock = NSLock()
    private var isReleased = false

    init(writingAt url: URL) {
        let thread = Thread { [acquired, released] in
            var error: NSError?
            NSFileCoordinator(filePresenter: nil).coordinate(writingItemAt: url, options: [], error: &error) { _ in
                acquired.signal()
                _ = released.wait(timeout: .now() + 10)
            }
        }
        thread.start()
        acquired.wait()
    }

    var hasReleased: Bool {
        lock.withLock { isReleased }
    }

    func release() {
        lock.withLock { isReleased = true }
        released.signal()
    }
}
