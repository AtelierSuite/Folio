import Foundation

public struct HolidayRepository: Sendable {
    public typealias DataLoader = @Sendable (URL) async throws -> Data

    public static let maximumCacheAge: TimeInterval = 7 * 24 * 60 * 60

    let cache: HolidayCache
    let loadData: DataLoader

    public init(cache: HolidayCache = HolidayCache(), loadData: @escaping DataLoader = HolidayRepository.download) {
        self.cache = cache
        self.loadData = loadData
    }

    /// Serves the cache while it is fresh and covers the years around `now`, and falls back to it when offline.
    @concurrent
    public func holidays(for source: HolidaySource, now: Date = .now) async -> [Holiday] {
        let years = Self.years(around: now)
        let cached = cache.entry(for: source)
        if let cached, now.timeIntervalSince(cached.fetchedAt) < Self.maximumCacheAge,
           cached.years.contains(years.lowerBound), cached.years.contains(years.upperBound) {
            return cached.holidays
        }
        do {
            return try await refresh(source, now: now)
        } catch {
            return cached?.holidays ?? []
        }
    }

    /// Downloads again regardless of the cache, keeping the cache untouched if the download fails.
    @concurrent
    @discardableResult
    public func refresh(_ source: HolidaySource, now: Date = .now) async throws -> [Holiday] {
        let years = Self.years(around: now)
        let holidays = try await fetch(source, years: years)
        cache.store(HolidayCacheEntry(fetchedAt: now, years: years, holidays: holidays), for: source)
        return holidays
    }

    public func lastUpdated(_ source: HolidaySource) -> Date? {
        cache.entry(for: source)?.fetchedAt
    }

    static func years(around date: Date) -> ClosedRange<Int> {
        let year = Calendar(identifier: .gregorian).component(.year, from: date)
        return (year - 1)...(year + 1)
    }

    private func fetch(_ source: HolidaySource, years: ClosedRange<Int>) async throws -> [Holiday] {
        try await withThrowingTaskGroup(of: [Holiday].self) { group in
            for url in source.urls(for: years) {
                group.addTask { try source.holidays(from: await loadData(url)) }
            }
            var holidays: [Holiday] = []
            for try await batch in group {
                holidays.append(contentsOf: batch)
            }
            return holidays.sorted { $0.day < $1.day }
        }
    }

    @concurrent
    public static func download(_ url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw HolidaySourceError.unexpectedResponse }
        return data
    }
}
