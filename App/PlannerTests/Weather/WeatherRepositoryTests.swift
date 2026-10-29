import Foundation
import Testing
@testable import Planner

struct WeatherRepositoryTests {
    private let location = WeatherLocationKey(WeatherFixtures.tokyo)
    private let calendar = Fixtures.calendar

    private func makeRepository(
        provider: CountingWeatherProvider,
        directory: TemporaryDirectory,
        now: Date
    ) -> WeatherRepository {
        let clock = Clock(now)
        return WeatherRepository(provider: provider, cache: WeatherCache(directory: directory.url), now: { clock.now })
    }

    @Test func consecutiveDaysAreFetchedInOneRequest() async throws {
        let provider = CountingWeatherProvider()
        let directory = try TemporaryDirectory()
        let now = Fixtures.date(2026, 10, 29, hour: 9)
        let repository = makeRepository(provider: provider, directory: directory, now: now)
        let days = WeatherFixtures.days(from: Fixtures.date(2026, 10, 29), count: 7)
        let weather = await repository.days(days, at: location, detail: .daily, calendar: calendar)
        #expect(provider.requests == [DateInterval(start: days[0].start, end: days[6].end)])
        #expect(weather.values.allSatisfy { $0.daily?.highCelsius == 20 })
    }

    @Test func cachedDaysAreNotFetchedAgainWithinTheHour() async throws {
        let provider = CountingWeatherProvider()
        let directory = try TemporaryDirectory()
        let now = Fixtures.date(2026, 10, 29, hour: 9)
        let days = WeatherFixtures.days(from: Fixtures.date(2026, 10, 29), count: 3)
        let first = makeRepository(provider: provider, directory: directory, now: now)
        _ = await first.days(days, at: location, detail: .daily, calendar: calendar)
        let second = makeRepository(provider: provider, directory: directory, now: now.addingTimeInterval(1800))
        _ = await second.days(days, at: location, detail: .daily, calendar: calendar)
        #expect(provider.requests.count == 1)
        let third = makeRepository(provider: provider, directory: directory, now: now.addingTimeInterval(3700))
        _ = await third.days(days, at: location, detail: .daily, calendar: calendar)
        #expect(provider.requests.count == 2)
    }

    @Test func pastDaysStayCachedForGood() async throws {
        let provider = CountingWeatherProvider()
        let directory = try TemporaryDirectory()
        let now = Fixtures.date(2026, 10, 29, hour: 9)
        let lastWeek = WeatherFixtures.days(from: Fixtures.date(2026, 10, 20), count: 7)
        _ = await makeRepository(provider: provider, directory: directory, now: now)
            .days(lastWeek, at: location, detail: .daily, calendar: calendar)
        _ = await makeRepository(provider: provider, directory: directory, now: now.addingTimeInterval(30 * 86400))
            .days(lastWeek, at: location, detail: .daily, calendar: calendar)
        #expect(provider.requests.count == 1)
    }

    @Test func daysBeyondTheForecastAreNotRequested() async throws {
        let provider = CountingWeatherProvider()
        let directory = try TemporaryDirectory()
        let now = Fixtures.date(2026, 10, 29, hour: 9)
        let repository = makeRepository(provider: provider, directory: directory, now: now)
        let days = WeatherFixtures.days(from: Fixtures.date(2026, 11, 5), count: 6)
        let weather = await repository.days(days, at: location, detail: .daily, calendar: calendar)
        #expect(provider.requests == [DateInterval(start: days[0].start, end: days[2].end)])
        #expect(weather[days[5].start]?.daily == nil)
        #expect(weather.count == 6)
    }

    @Test func hourlyRequestsAreSplitIntoTenDayBatches() async throws {
        let provider = CountingWeatherProvider()
        let directory = try TemporaryDirectory()
        let now = Fixtures.date(2026, 10, 29, hour: 9)
        let repository = makeRepository(provider: provider, directory: directory, now: now)
        let days = WeatherFixtures.days(from: Fixtures.date(2026, 9, 1), count: 25)
        let weather = await repository.days(days, at: location, detail: .dailyAndHourly, calendar: calendar)
        #expect(provider.requests.count == 3)
        #expect(weather[days[0].start]?.hourly.count == 24)
    }

    @Test func staleDataIsKeptWhenAFetchFails() async throws {
        let provider = CountingWeatherProvider()
        let directory = try TemporaryDirectory()
        let now = Fixtures.date(2026, 10, 29, hour: 9)
        let days = WeatherFixtures.days(from: Fixtures.date(2026, 10, 29), count: 2)
        _ = await makeRepository(provider: provider, directory: directory, now: now)
            .days(days, at: location, detail: .daily, calendar: calendar)
        provider.fails = true
        let weather = await makeRepository(provider: provider, directory: directory, now: now.addingTimeInterval(7200))
            .days(days, at: location, detail: .daily, calendar: calendar)
        #expect(provider.requests.count == 2)
        #expect(weather[days[0].start]?.daily != nil)
    }

    @Test func dailyForecastMatchesTheNearestMidnight() {
        let dayStart = Fixtures.date(2026, 10, 29)
        let forecast = WeatherForecast(daily: [
            DailyWeather(
                date: dayStart.addingTimeInterval(-9 * 3600), symbolName: "sun.max", conditionDescription: "Clear",
                highCelsius: 21, lowCelsius: 11, precipitationChance: 0, sunrise: nil, sunset: nil
            ),
            DailyWeather(
                date: dayStart.addingTimeInterval(15 * 3600), symbolName: "cloud", conditionDescription: "Cloudy",
                highCelsius: 18, lowCelsius: 9, precipitationChance: 0, sunrise: nil, sunset: nil
            )
        ], hourly: [])
        let day = forecast.day(for: DateInterval(start: dayStart, duration: 86400))
        #expect(day.daily?.highCelsius == 21)
    }
}

private final class Clock: Sendable {
    let now: Date

    init(_ now: Date) {
        self.now = now
    }
}

struct WeatherRequestBatchesTests {
    @Test func gapsStartANewBatch() {
        let days = WeatherFixtures.days(from: Fixtures.date(2026, 10, 1), count: 6)
        let batches = WeatherRequestBatches.batches(for: [days[4], days[0], days[1], days[3]], maximumDays: 10)
        #expect(batches == [[days[0], days[1]], [days[3], days[4]]])
    }

    @Test func longRunsAreCapped() {
        let days = WeatherFixtures.days(from: Fixtures.date(2026, 10, 1), count: 5)
        #expect(WeatherRequestBatches.batches(for: days, maximumDays: 2).map(\.count) == [2, 2, 1])
    }
}
