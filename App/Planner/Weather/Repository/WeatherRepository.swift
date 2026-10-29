import Foundation

/// Serves weather from the App Group cache and only asks the provider for days that are
/// missing or stale, one request per run of consecutive days.
public actor WeatherRepository {
    private let provider: any WeatherProvider
    private let cache: WeatherCache
    private let policy: WeatherCachePolicy
    private let now: @Sendable () -> Date
    private var inFlight: [RequestKey: Task<[Date: WeatherDay]?, Never>] = [:]
    private var attribution: WeatherAttribution?

    public init(
        provider: any WeatherProvider,
        cache: WeatherCache = WeatherCache(),
        policy: WeatherCachePolicy = WeatherCachePolicy(),
        now: @escaping @Sendable () -> Date = { .now }
    ) {
        self.provider = provider
        self.cache = cache
        self.policy = policy
        self.now = now
    }

    public func days(
        _ days: [DateInterval],
        at location: WeatherLocationKey,
        detail: WeatherDetail,
        calendar: Calendar
    ) async -> [Date: WeatherDay] {
        let now = now()
        var result: [Date: WeatherDay] = [:]
        var stale: [Date: WeatherDay] = [:]
        var missing: [DateInterval] = []
        for day in days {
            guard policy.canFetch(day, now: now, calendar: calendar) else {
                result[day.start] = WeatherDay(dayStart: day.start, daily: nil, hourly: [])
                continue
            }
            if let entry = cache.entry(for: location, dayStart: day.start, calendar: calendar), entry.covers(detail) {
                if policy.isFresh(entry, dayEnd: day.end, now: now) {
                    result[day.start] = entry.day
                    continue
                }
                stale[day.start] = entry.day
            }
            missing.append(day)
        }
        let maximumDays = detail == .dailyAndHourly ? policy.maximumHourlyDaysPerRequest : Int.max
        for batch in WeatherRequestBatches.batches(for: missing, maximumDays: maximumDays) {
            let fetched = await fetch(batch, at: location, detail: detail, calendar: calendar, now: now)
            for day in batch {
                result[day.start] = fetched?[day.start]
                    ?? stale[day.start]
                    ?? WeatherDay(dayStart: day.start, daily: nil, hourly: [])
            }
        }
        return result
    }

    public func currentAttribution() async -> WeatherAttribution {
        if let attribution { return attribution }
        if let fetched = try? await provider.attribution() {
            attribution = fetched
            cache.store(fetched)
            return fetched
        }
        return cache.attribution ?? .placeholder
    }

    private func fetch(
        _ batch: [DateInterval],
        at location: WeatherLocationKey,
        detail: WeatherDetail,
        calendar: Calendar,
        now: Date
    ) async -> [Date: WeatherDay]? {
        guard let first = batch.first, let last = batch.last else { return [:] }
        let interval = DateInterval(start: first.start, end: last.end)
        let key = RequestKey(location: location, interval: interval, detail: detail)
        if let running = inFlight[key] {
            return await running.value
        }
        let task = Task { [provider, cache] () -> [Date: WeatherDay]? in
            guard let forecast = try? await provider.forecast(
                at: location.coordinate, in: interval, detail: detail
            ) else { return nil }
            var days: [Date: WeatherDay] = [:]
            for day in batch {
                let weatherDay = forecast.day(for: day)
                days[day.start] = weatherDay
                let entry = WeatherCacheEntry(
                    day: weatherDay, fetchedAt: now, includesHourly: detail == .dailyAndHourly
                )
                cache.store(entry, for: location, calendar: calendar)
            }
            return days
        }
        inFlight[key] = task
        let days = await task.value
        inFlight[key] = nil
        return days
    }

    private struct RequestKey: Hashable {
        let location: WeatherLocationKey
        let interval: DateInterval
        let detail: WeatherDetail
    }
}
