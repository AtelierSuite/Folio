import Foundation
import Testing
@testable import Planner

struct WidgetWeatherReaderTests {
    private let today = Fixtures.date(2026, 10, 29)

    private func makeSettings(enabled: Bool) throws -> WeatherSettings {
        let defaults = try #require(UserDefaults(suiteName: "WidgetWeatherReaderTests.\(UUID().uuidString)"))
        let settings = WeatherSettings(defaults: defaults)
        settings.isEnabled = enabled
        settings.locationMode = .chosen
        settings.chosenPlace = WeatherPlace(name: "Tokyo", coordinate: WeatherFixtures.tokyo)
        return settings
    }

    private func makeCache(in directory: TemporaryDirectory) -> WeatherCache {
        let cache = WeatherCache(directory: directory.url)
        let daily = DailyWeather(
            date: today, symbolName: "sun.max", conditionDescription: "Clear",
            highCelsius: 21, lowCelsius: 12, precipitationChance: 0, sunrise: nil, sunset: nil
        )
        let entry = WeatherCacheEntry(
            day: WeatherDay(dayStart: today, daily: daily, hourly: []), fetchedAt: today, includesHourly: false
        )
        cache.store(entry, for: WeatherLocationKey(WeatherFixtures.tokyo), calendar: Fixtures.calendar)
        return cache
    }

    @Test func readsCachedWeatherForTheHomeLocation() throws {
        let directory = try TemporaryDirectory()
        let reader = WidgetWeatherReader(cache: makeCache(in: directory), settings: try makeSettings(enabled: true))
        let tomorrow = Fixtures.date(2026, 10, 30)
        let weather = reader.dailyWeather(forDaysStarting: [today, tomorrow], calendar: Fixtures.calendar)
        #expect(weather[today]?.symbolName == "sun.max")
        #expect(weather[tomorrow] == nil)
    }

    @Test func readsNothingWhenWeatherIsOff() throws {
        let directory = try TemporaryDirectory()
        let reader = WidgetWeatherReader(cache: makeCache(in: directory), settings: try makeSettings(enabled: false))
        #expect(reader.dailyWeather(forDaysStarting: [today], calendar: Fixtures.calendar).isEmpty)
    }

    @Test func agendaSnapshotsCarryTodaysWeather() async throws {
        let directory = try TemporaryDirectory()
        let defaults = try #require(UserDefaults(suiteName: "WidgetWeatherReaderTests.\(UUID().uuidString)"))
        let loader = WidgetSnapshotLoader(
            source: FakeCalendarDataSource(),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            weatherReader: WidgetWeatherReader(
                cache: makeCache(in: directory), settings: try makeSettings(enabled: true)
            )
        )
        let now = Fixtures.date(2026, 10, 29, hour: 9)
        let request = WidgetSnapshotRequest.upcoming(from: now, calendar: Fixtures.calendar, includesWeather: true)
        let snapshot = await loader.load(request, at: now, calendar: Fixtures.calendar)
        #expect(snapshot.weather(on: now, calendar: Fixtures.calendar)?.highCelsius == 21)
        let withoutWeather = await loader.load(.reminders(), at: now, calendar: Fixtures.calendar)
        #expect(withoutWeather.weather.isEmpty)
    }
}
