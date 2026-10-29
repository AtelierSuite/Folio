import Foundation

public struct WeatherCacheEntry: Sendable, Hashable, Codable {
    public let day: WeatherDay
    public let fetchedAt: Date
    public let includesHourly: Bool

    public init(day: WeatherDay, fetchedAt: Date, includesHourly: Bool) {
        self.day = day
        self.fetchedAt = fetchedAt
        self.includesHourly = includesHourly
    }

    public func covers(_ detail: WeatherDetail) -> Bool {
        detail == .daily || includesHourly
    }
}
