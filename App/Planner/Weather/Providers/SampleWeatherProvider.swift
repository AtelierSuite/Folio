#if DEBUG
import Foundation

/// Made-up but repeatable weather for Debug builds and UI tests, where WeatherKit isn't signed in.
public struct SampleWeatherProvider: WeatherProvider {
    public static let launchArgument = "-FolioSampleWeather"
    public static let samplePlace = WeatherPlace(
        name: "Tokyo", coordinate: PlannerCoordinate(latitude: 35.68, longitude: 139.76)
    )

    private let calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    public func forecast(
        at coordinate: PlannerCoordinate,
        in interval: DateInterval,
        detail: WeatherDetail
    ) async throws -> WeatherForecast {
        var daily: [DailyWeather] = []
        var hourly: [HourlyWeather] = []
        var dayStart = calendar.startOfDay(for: interval.start)
        while dayStart < interval.end {
            let day = sampleDay(startingAt: dayStart, at: coordinate)
            daily.append(day)
            if detail == .dailyAndHourly {
                hourly += sampleHours(for: day)
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: dayStart) else { break }
            dayStart = next
        }
        return WeatherForecast(daily: daily, hourly: hourly)
    }

    public func attribution() async throws -> WeatherAttribution {
        .placeholder
    }

    private func sampleDay(startingAt dayStart: Date, at coordinate: PlannerCoordinate) -> DailyWeather {
        let seed = Int(dayStart.timeIntervalSince1970 / 86400) + Int(coordinate.latitude * 7)
        let condition = SampleCondition.allCases[abs(seed) % SampleCondition.allCases.count]
        let high = 14.0 + Double(abs(seed * 7) % 9)
        let low = high - 5 - Double(abs(seed * 3) % 4)
        return DailyWeather(
            date: dayStart,
            symbolName: condition.symbolName,
            conditionDescription: condition.localizedDescription,
            highCelsius: high,
            lowCelsius: low,
            precipitationChance: condition.precipitationChance,
            sunrise: dayStart.addingTimeInterval(6 * 3600 + 1200),
            sunset: dayStart.addingTimeInterval(17 * 3600 + 600)
        )
    }

    private func sampleHours(for day: DailyWeather) -> [HourlyWeather] {
        (0..<24).map { hour in
            let date = day.date.addingTimeInterval(Double(hour) * 3600)
            let warmth = (1 - cos(Double(hour - 2) / 24 * 2 * .pi)) / 2
            let isDaylight = date >= (day.sunrise ?? date) && date < (day.sunset ?? date)
            let afternoonPeak = hour >= 12 && hour <= 18 ? 1.0 : 0.6
            return HourlyWeather(
                date: date,
                symbolName: isDaylight ? day.symbolName : "moon.stars.fill",
                temperatureCelsius: day.lowCelsius + (day.highCelsius - day.lowCelsius) * warmth,
                precipitationChance: min(1, day.precipitationChance * afternoonPeak),
                isDaylight: isDaylight
            )
        }
    }
}

private enum SampleCondition: CaseIterable {
    case clear
    case partlyCloudy
    case cloudy
    case rain

    var symbolName: String {
        switch self {
        case .clear: "sun.max.fill"
        case .partlyCloudy: "cloud.sun.fill"
        case .cloudy: "cloud.fill"
        case .rain: "cloud.rain.fill"
        }
    }

    var precipitationChance: Double {
        switch self {
        case .clear: 0
        case .partlyCloudy: 0.1
        case .cloudy: 0.3
        case .rain: 0.8
        }
    }

    var localizedDescription: String {
        switch self {
        case .clear: String(localized: "Condition.Clear", table: "Weather", bundle: #bundle)
        case .partlyCloudy: String(localized: "Condition.PartlyCloudy", table: "Weather", bundle: #bundle)
        case .cloudy: String(localized: "Condition.Cloudy", table: "Weather", bundle: #bundle)
        case .rain: String(localized: "Condition.Rain", table: "Weather", bundle: #bundle)
        }
    }
}
#endif
