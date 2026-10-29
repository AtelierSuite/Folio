import Foundation

public struct WeatherCachePolicy: Sendable {
    /// WeatherKit has historical data from August 2021.
    public static let earliestHistoricalDate = Date(timeIntervalSince1970: 1_627_776_000)

    public var maximumAge: TimeInterval
    public var forecastDays: Int
    public var maximumHourlyDaysPerRequest: Int

    public init(maximumAge: TimeInterval = 3600, forecastDays: Int = 10, maximumHourlyDaysPerRequest: Int = 10) {
        self.maximumAge = maximumAge
        self.forecastDays = forecastDays
        self.maximumHourlyDaysPerRequest = maximumHourlyDaysPerRequest
    }

    /// Days that had ended before the fetch never change, so they stay cached for good.
    public func isFresh(_ entry: WeatherCacheEntry, dayEnd: Date, now: Date) -> Bool {
        if entry.fetchedAt >= dayEnd { return true }
        let age = now.timeIntervalSince(entry.fetchedAt)
        return age >= 0 && age < maximumAge
    }

    public func fetchableInterval(now: Date, calendar: Calendar) -> DateInterval {
        let today = calendar.startOfDay(for: now)
        let end = calendar.date(byAdding: .day, value: forecastDays, to: today) ?? today
        return DateInterval(start: Self.earliestHistoricalDate, end: max(end, Self.earliestHistoricalDate))
    }

    public func canFetch(_ day: DateInterval, now: Date, calendar: Calendar) -> Bool {
        let fetchable = fetchableInterval(now: now, calendar: calendar)
        return day.start >= fetchable.start && day.start < fetchable.end
    }
}
