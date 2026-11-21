import Foundation

/// Keeps the most recently used reads, and lets callers missing the same key share one read.
/// Failed reads (`nil`) aren't kept, and reads still running when the cache is cleared aren't stored.
@MainActor
final class SharedReadCache<Key: Hashable & Sendable, Value: Sendable> {
    private let limit: Int
    private var values: [Key: Value] = [:]
    private var recentKeys: [Key] = []
    private var runningReads: [Key: Task<Value?, Never>] = [:]
    private var generation = 0

    init(limit: Int) {
        self.limit = limit
    }

    var keys: [Key] {
        recentKeys
    }

    subscript(key: Key) -> Value? {
        values[key]
    }

    func value(for key: Key, read: @escaping @Sendable () async -> Value?) async -> Value? {
        if let value = values[key] {
            markUsed(key)
            return value
        }
        if let running = runningReads[key] {
            return await running.value
        }
        let startedGeneration = generation
        let running = Task { await read() }
        runningReads[key] = running
        let value = await running.value
        guard generation == startedGeneration else { return value }
        runningReads[key] = nil
        if let value {
            store(value, for: key)
        }
        return value
    }

    func store(_ value: Value, for key: Key) {
        values[key] = value
        markUsed(key)
        while recentKeys.count > limit {
            values[recentKeys.removeFirst()] = nil
        }
    }

    func removeAll() {
        values.removeAll()
        recentKeys.removeAll()
        runningReads.removeAll()
        generation += 1
    }

    private func markUsed(_ key: Key) {
        recentKeys.removeAll { $0 == key }
        recentKeys.append(key)
    }
}
