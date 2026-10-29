import Foundation
import Testing
@testable import Planner

@MainActor
struct WeatherStoreTests {
    private func makeStore(
        provider: CountingWeatherProvider = CountingWeatherProvider(),
        directory: TemporaryDirectory,
        locator: FakeLocator? = nil,
        isEnabled: Bool = true
    ) throws -> WeatherStore {
        let defaults = try #require(UserDefaults(suiteName: "WeatherStoreTests.\(UUID().uuidString)"))
        let settings = WeatherSettings(defaults: defaults)
        settings.isEnabled = isEnabled
        let now = Fixtures.date(2026, 10, 29, hour: 9)
        return WeatherStore(
            repository: WeatherRepository(
                provider: provider, cache: WeatherCache(directory: directory.url), now: { now }
            ),
            settings: settings,
            locator: locator,
            now: { now }
        )
    }

    @Test func disabledWeatherIsEmpty() async throws {
        let directory = try TemporaryDirectory()
        let store = try makeStore(directory: directory, isEnabled: false)
        store.choose(WeatherPlace(name: "Tokyo", coordinate: WeatherFixtures.tokyo))
        let snapshot = await store.snapshot(
            for: WeatherFixtures.days(from: Fixtures.date(2026, 10, 29), count: 1),
            calendar: Fixtures.calendar, events: [], detail: .daily
        )
        #expect(snapshot == .empty)
    }

    @Test func withoutALocationThereIsNoWeather() async throws {
        let directory = try TemporaryDirectory()
        let store = try makeStore(directory: directory, locator: FakeLocator(status: .denied))
        #expect(!store.hasLocation)
        let snapshot = await store.snapshot(
            for: WeatherFixtures.days(from: Fixtures.date(2026, 10, 29), count: 1),
            calendar: Fixtures.calendar, events: [], detail: .daily
        )
        #expect(!snapshot.hasWeather)
    }

    @Test func currentLocationIsUsedWhenAllowed() async throws {
        let directory = try TemporaryDirectory()
        let locator = FakeLocator(status: .granted, coordinate: WeatherFixtures.osaka)
        let store = try makeStore(directory: directory, locator: locator)
        store.choose(WeatherPlace(name: "Tokyo", coordinate: WeatherFixtures.tokyo))
        store.setLocationMode(.current)
        #expect(await store.homeCoordinate() == WeatherFixtures.osaka)
        #expect(await store.homeCoordinate() == WeatherFixtures.osaka)
        #expect(locator.requestCount == 1)
    }

    @Test func chosenPlaceIsUsedWithoutLocationAccess() async throws {
        let directory = try TemporaryDirectory()
        let store = try makeStore(directory: directory, locator: FakeLocator(status: .denied))
        store.choose(WeatherPlace(name: "Tokyo", coordinate: WeatherFixtures.tokyo))
        #expect(store.locationMode == .chosen)
        #expect(await store.homeCoordinate() == WeatherFixtures.tokyo)
    }

    @Test func rainyEventsAreHighlighted() async throws {
        let provider = CountingWeatherProvider()
        provider.precipitationChance = 0.7
        let directory = try TemporaryDirectory()
        let store = try makeStore(provider: provider, directory: directory)
        store.choose(WeatherPlace(name: "Tokyo", coordinate: WeatherFixtures.tokyo))
        let walk = WeatherFixtures.event(
            local: "walk", start: Fixtures.date(2026, 10, 29, hour: 15), coordinate: WeatherFixtures.shibuya
        )
        let snapshot = await store.snapshot(
            for: WeatherFixtures.days(from: Fixtures.date(2026, 10, 29), count: 1),
            calendar: Fixtures.calendar, events: [walk], detail: .dailyAndHourly
        )
        #expect(snapshot.hasWeather)
        #expect(snapshot.rainHighlights.map(\.eventID) == [walk.id])
        #expect(snapshot.attribution == .placeholder)
        #expect(provider.requests.count == 2)
    }
}

@MainActor
final class FakeLocator: CurrentLocating {
    var authorizationStatus: PermissionStatus
    let coordinate: PlannerCoordinate?
    private(set) var requestCount = 0

    init(status: PermissionStatus, coordinate: PlannerCoordinate? = nil) {
        authorizationStatus = status
        self.coordinate = coordinate
    }

    func currentCoordinate() async -> PlannerCoordinate? {
        requestCount += 1
        return coordinate
    }
}
