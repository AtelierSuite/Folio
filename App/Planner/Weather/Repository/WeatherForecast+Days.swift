import Foundation

extension WeatherForecast {
    /// The daily forecast is dated at local midnight of the forecast location, which can be
    /// a few hours off the calendar's midnight, so the closest one within half a day wins.
    func day(for interval: DateInterval) -> WeatherDay {
        let halfDay: TimeInterval = 12 * 3600
        let daily = daily
            .filter { abs($0.date.timeIntervalSince(interval.start)) < halfDay }
            .min { abs($0.date.timeIntervalSince(interval.start)) < abs($1.date.timeIntervalSince(interval.start)) }
        let hourly = hourly
            .filter { $0.date >= interval.start && $0.date < interval.end }
            .sorted { $0.date < $1.date }
        return WeatherDay(dayStart: interval.start, daily: daily, hourly: hourly)
    }
}
