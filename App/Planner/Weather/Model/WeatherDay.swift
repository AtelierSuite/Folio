import Foundation

/// The weather for one calendar day at one location. `daily` is `nil` when there is no data
/// for the day (too far ahead, or too far back for historical data).
public struct WeatherDay: Sendable, Hashable, Codable {
    public let dayStart: Date
    public let daily: DailyWeather?
    public let hourly: [HourlyWeather]

    public init(dayStart: Date, daily: DailyWeather?, hourly: [HourlyWeather]) {
        self.dayStart = dayStart
        self.daily = daily
        self.hourly = hourly
    }

    public func hour(containing date: Date) -> HourlyWeather? {
        hourly.last { $0.date <= date && date < $0.date.addingTimeInterval(3600) }
    }
}
