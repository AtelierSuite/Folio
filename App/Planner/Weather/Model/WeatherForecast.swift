import Foundation

/// What a provider returns for one location and date range.
public struct WeatherForecast: Sendable, Hashable {
    public let daily: [DailyWeather]
    public let hourly: [HourlyWeather]

    public init(daily: [DailyWeather], hourly: [HourlyWeather]) {
        self.daily = daily
        self.hourly = hourly
    }
}
