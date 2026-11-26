import Foundation
import Testing
@testable import Planner

struct WeatherRefreshScheduleTests {
    @Test func runsJustAfterTheComingMidnight() {
        let now = Fixtures.date(2026, 10, 29, hour: 21)
        let next = WeatherRefreshSchedule.nextRunDate(after: now, calendar: Fixtures.calendar)
        #expect(next == Fixtures.date(2026, 10, 30).addingTimeInterval(WeatherRefreshSchedule.delayAfterMidnight))
    }

    @Test func runsTonightWhenScheduledInTheMinutesAfterMidnight() {
        let now = Fixtures.date(2026, 10, 29).addingTimeInterval(60)
        let next = WeatherRefreshSchedule.nextRunDate(after: now, calendar: Fixtures.calendar)
        #expect(next == Fixtures.date(2026, 10, 29).addingTimeInterval(WeatherRefreshSchedule.delayAfterMidnight))
    }

    @MainActor
    @Test func refreshFetchesTodayAndTomorrowWithHours() async throws {
        let directory = try TemporaryDirectory()
        let defaults = try #require(UserDefaults(suiteName: "WeatherRefreshScheduleTests.\(UUID().uuidString)"))
        let settings = WeatherSettings(defaults: defaults)
        settings.isEnabled = true
        settings.chosenPlace = WeatherPlace(name: "Tokyo", coordinate: WeatherFixtures.tokyo)
        settings.locationMode = .chosen
        let cache = WeatherCache(directory: directory.url)
        let now = Fixtures.date(2026, 10, 29).addingTimeInterval(300)
        let store = WeatherStore(
            repository: WeatherRepository(
                provider: SampleWeatherProvider(calendar: Fixtures.calendar), cache: cache, now: { now }
            ),
            settings: settings,
            locator: nil,
            now: { now }
        )
        #expect(await store.refreshWidgetForecast(calendar: Fixtures.calendar))
        let reader = WidgetWeatherReader(cache: cache, settings: settings)
        #expect(reader.hourlyWeather(at: now, calendar: Fixtures.calendar) != nil)
    }
}
