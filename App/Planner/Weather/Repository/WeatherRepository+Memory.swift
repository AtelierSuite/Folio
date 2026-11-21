import Foundation

extension WeatherRepository {
    struct MemoryKey: Hashable {
        let location: WeatherLocationKey
        let dayStart: Date
    }

    static let memoryLimit = 500

    /// A widget may have refreshed the file since, so a stale in-memory entry falls through to the disk cache.
    func cachedEntry(
        for location: WeatherLocationKey,
        day: DateInterval,
        detail: WeatherDetail,
        now: Date,
        calendar: Calendar
    ) -> WeatherCacheEntry? {
        let key = MemoryKey(location: location, dayStart: day.start)
        let remembered = memory[key].flatMap { $0.covers(detail) ? $0 : nil }
        if let remembered, policy.isFresh(remembered, dayEnd: day.end, now: now) {
            return remembered
        }
        guard let stored = cache.entry(for: location, dayStart: day.start, calendar: calendar),
              stored.covers(detail),
              stored.fetchedAt > remembered?.fetchedAt ?? .distantPast else {
            return remembered
        }
        remember(stored, for: key)
        return stored
    }

    func remember(
        _ days: some Sequence<WeatherDay>,
        at location: WeatherLocationKey,
        fetchedAt: Date,
        includesHourly: Bool
    ) {
        for day in days {
            let entry = WeatherCacheEntry(day: day, fetchedAt: fetchedAt, includesHourly: includesHourly)
            remember(entry, for: MemoryKey(location: location, dayStart: day.dayStart))
        }
    }

    private func remember(_ entry: WeatherCacheEntry, for key: MemoryKey) {
        if memory[key] == nil, memory.count >= Self.memoryLimit {
            memory.removeAll()
        }
        memory[key] = entry
    }
}
