import Foundation

/// The most recently used windows of one kind of item, plus the fetches still running for others.
final class WindowCache<Item: Sendable> {
    private let capacity: Int
    private var windows: [CachedWindow<Item>] = []
    private var inFlight: [DateInterval: Task<[Item], Never>] = [:]

    init(capacity: Int) {
        self.capacity = capacity
    }

    var intervals: [DateInterval] {
        windows.map(\.interval)
    }

    func items(covering interval: DateInterval) -> [Item]? {
        guard let index = windows.firstIndex(where: { $0.covers(interval) }) else { return nil }
        let window = windows.remove(at: index)
        windows.insert(window, at: 0)
        return window.items
    }

    func fetch(covering interval: DateInterval) -> Task<[Item], Never>? {
        inFlight.first { window, _ in
            window.start <= interval.start && interval.end <= window.end
        }?.value
    }

    func begin(_ fetch: Task<[Item], Never>, for window: DateInterval) {
        inFlight[window] = fetch
    }

    /// Keeps the result only if the fetch wasn't dropped by `removeAll()` while it ran.
    func finish(_ fetch: Task<[Item], Never>, for window: DateInterval, items: [Item]) {
        guard inFlight[window] == fetch else { return }
        inFlight[window] = nil
        windows.removeAll { window.start <= $0.interval.start && $0.interval.end <= window.end }
        windows.insert(CachedWindow(interval: window, items: items), at: 0)
        if windows.count > capacity {
            windows.removeLast(windows.count - capacity)
        }
    }

    func removeAll() {
        windows.removeAll()
        inFlight.removeAll()
    }
}
