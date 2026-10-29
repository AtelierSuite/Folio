import Foundation

/// Reads the daily weather the app cached in the App Group; widgets never fetch weather.
public struct WidgetWeatherReader: Sendable {
    private let cache: WeatherCache
    private let settings: WeatherSettings

    public init(cache: WeatherCache = WeatherCache(), settings: WeatherSettings = WeatherSettings()) {
        self.cache = cache
        self.settings = settings
    }

    public func dailyWeather(forDaysStarting dayStarts: [Date], calendar: Calendar) -> [Date: DailyWeather] {
        guard settings.isEnabled, let home = homeCoordinate else { return [:] }
        let location = WeatherLocationKey(home)
        var weather: [Date: DailyWeather] = [:]
        for dayStart in dayStarts {
            weather[dayStart] = cache.entry(for: location, dayStart: dayStart, calendar: calendar)?.day.daily
        }
        return weather
    }

    private var homeCoordinate: PlannerCoordinate? {
        switch settings.locationMode {
        case .chosen: settings.chosenPlace?.coordinate
        case .current: settings.lastLocationFix?.coordinate
        }
    }
}
