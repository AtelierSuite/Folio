import Foundation
import Testing
@testable import Planner

struct WeatherCachePruningTests {
    @Test func removesOnlyLocationsUnusedSinceTheCutoff() throws {
        let directory = try TemporaryDirectory()
        let cache = WeatherCache(directory: directory.url)
        let dayStart = Fixtures.date(2026, 10, 29)
        let entry = WeatherCacheEntry(
            day: WeatherDay(dayStart: dayStart, daily: nil, hourly: []), fetchedAt: dayStart, includesHourly: false
        )
        let home = WeatherLocationKey(WeatherFixtures.tokyo)
        let trip = WeatherLocationKey(PlannerCoordinate(latitude: 48.85, longitude: 2.35))
        cache.store(entry, for: home, calendar: Fixtures.calendar)
        cache.store(entry, for: trip, calendar: Fixtures.calendar)
        cache.store(WeatherAttribution.placeholder)
        let tripFolder = directory.url.appending(path: trip.pathComponent, directoryHint: .isDirectory)
        try FileManager.default.setAttributes(
            [.modificationDate: Date.now.addingTimeInterval(-40 * 86400)], ofItemAtPath: tripFolder.path()
        )
        cache.removeLocations(unusedSince: .now.addingTimeInterval(-WeatherCache.unusedLocationLifetime))
        #expect(cache.entry(for: home, dayStart: dayStart, calendar: Fixtures.calendar) != nil)
        #expect(cache.entry(for: trip, dayStart: dayStart, calendar: Fixtures.calendar) == nil)
        #expect(cache.attribution != nil)
    }
}
