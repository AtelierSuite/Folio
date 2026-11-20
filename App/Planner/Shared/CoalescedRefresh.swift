import Foundation

/// Runs one refresh at a time. Requests that arrive while one is running share it and queue a
/// single extra pass, so a burst of change callbacks costs at most two refreshes.
@MainActor
final class CoalescedRefresh {
    private var running: Task<Void, Never>?
    private var isRequestedAgain = false

    func run(_ refresh: @escaping @MainActor () async -> Void) async {
        if let running {
            isRequestedAgain = true
            await running.value
            return
        }
        let task = Task { @MainActor in
            repeat {
                isRequestedAgain = false
                await refresh()
            } while isRequestedAgain
            running = nil
        }
        running = task
        await task.value
    }
}
