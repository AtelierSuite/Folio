import Foundation
@testable import Planner

enum WeatherFixtures {
    static let tokyo = PlannerCoordinate(latitude: 35.68, longitude: 139.76)
    static let shibuya = PlannerCoordinate(latitude: 35.66, longitude: 139.70)
    static let osaka = PlannerCoordinate(latitude: 34.69, longitude: 135.50)

    static func days(from start: Date, count: Int) -> [DateInterval] {
        TimelineDays(startingOn: start, count: count, calendar: Fixtures.calendar).intervals
    }

    static func event(
        local: String,
        start: Date,
        hours: Double = 1,
        coordinate: PlannerCoordinate?,
        location: String? = nil,
        isAllDay: Bool = false
    ) -> CalendarEvent {
        CalendarEvent(
            reference: Fixtures.reference(external: "external-\(local)", local: local),
            calendarIdentifier: "calendar-1",
            title: local,
            location: location,
            coordinate: coordinate,
            startDate: start,
            endDate: start.addingTimeInterval(hours * 3600),
            isAllDay: isAllDay
        )
    }
}

final class CountingWeatherProvider: WeatherProvider, @unchecked Sendable {
    private let lock = NSLock()
    private var recordedRequests: [DateInterval] = []
    var precipitationChance = 0.0
    var fails = false

    var requests: [DateInterval] {
        lock.withLock { recordedRequests }
    }

    func forecast(
        at coordinate: PlannerCoordinate,
        in interval: DateInterval,
        detail: WeatherDetail
    ) async throws -> WeatherForecast {
        let (chance, shouldFail) = lock.withLock {
            recordedRequests.append(interval)
            return (precipitationChance, fails)
        }
        if shouldFail { throw URLError(.notConnectedToInternet) }
        var daily: [DailyWeather] = []
        var hourly: [HourlyWeather] = []
        var dayStart = interval.start
        while dayStart < interval.end {
            daily.append(DailyWeather(
                date: dayStart, symbolName: "sun.max", conditionDescription: "Clear",
                highCelsius: 20, lowCelsius: 10, precipitationChance: chance,
                sunrise: dayStart.addingTimeInterval(6 * 3600), sunset: dayStart.addingTimeInterval(18 * 3600)
            ))
            if detail == .dailyAndHourly {
                hourly += (0..<24).map { hour in
                    HourlyWeather(
                        date: dayStart.addingTimeInterval(Double(hour) * 3600), symbolName: "sun.max",
                        temperatureCelsius: 15, precipitationChance: chance, isDaylight: hour >= 6 && hour < 18
                    )
                }
            }
            dayStart = dayStart.addingTimeInterval(86400)
        }
        return WeatherForecast(daily: daily, hourly: hourly)
    }

    func attribution() async throws -> WeatherAttribution {
        .placeholder
    }
}
