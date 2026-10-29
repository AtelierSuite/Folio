import CoreLocation
import Foundation
import WeatherKit

public struct WeatherKitProvider: WeatherProvider {
    public init() {}

    public func forecast(
        at coordinate: PlannerCoordinate,
        in interval: DateInterval,
        detail: WeatherDetail
    ) async throws -> WeatherForecast {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let service = WeatherService.shared
        switch detail {
        case .daily:
            let daily = try await service.weather(
                for: location, including: .daily(startDate: interval.start, endDate: interval.end)
            )
            return WeatherForecast(daily: daily.forecast.map(DailyWeather.init), hourly: [])
        case .dailyAndHourly:
            let (daily, hourly) = try await service.weather(
                for: location,
                including: .daily(startDate: interval.start, endDate: interval.end),
                .hourly(startDate: interval.start, endDate: interval.end)
            )
            return WeatherForecast(
                daily: daily.forecast.map(DailyWeather.init),
                hourly: hourly.forecast.map(HourlyWeather.init)
            )
        }
    }

    public func attribution() async throws -> WeatherAttribution {
        let attribution = try await WeatherService.shared.attribution
        return WeatherAttribution(
            serviceName: attribution.serviceName,
            legalPageURL: attribution.legalPageURL,
            markLightURL: attribution.combinedMarkLightURL,
            markDarkURL: attribution.combinedMarkDarkURL
        )
    }
}

extension DailyWeather {
    init(_ day: DayWeather) {
        self.init(
            date: day.date,
            symbolName: day.symbolName,
            conditionDescription: day.condition.description,
            highCelsius: day.highTemperature.converted(to: .celsius).value,
            lowCelsius: day.lowTemperature.converted(to: .celsius).value,
            precipitationChance: day.precipitationChance,
            sunrise: day.sun.sunrise,
            sunset: day.sun.sunset
        )
    }
}

extension HourlyWeather {
    init(_ hour: HourWeather) {
        self.init(
            date: hour.date,
            symbolName: hour.symbolName,
            temperatureCelsius: hour.temperature.converted(to: .celsius).value,
            precipitationChance: hour.precipitationChance,
            isDaylight: hour.isDaylight
        )
    }
}
