import Foundation
import Testing
@testable import Planner

struct WeatherCacheTests {
    private let location = WeatherLocationKey(WeatherFixtures.tokyo)

    private func entry(dayStart: Date, fetchedAt: Date, includesHourly: Bool = false) -> WeatherCacheEntry {
        WeatherCacheEntry(
            day: WeatherDay(dayStart: dayStart, daily: nil, hourly: []),
            fetchedAt: fetchedAt,
            includesHourly: includesHourly
        )
    }

    @Test func dayKeyUsesTheCalendarDay() {
        #expect(WeatherCache.dayKey(for: Fixtures.date(2026, 3, 7), calendar: Fixtures.calendar) == "2026-03-07")
    }

    @Test func filesAreGroupedByLocation() throws {
        let directory = try TemporaryDirectory()
        let cache = WeatherCache(directory: directory.url)
        let url = cache.fileURL(for: location, dayKey: "2026-10-29")
        #expect(url.path().hasSuffix("/35.7_139.8/2026-10-29.json"))
    }

    @Test func storedEntriesRoundTrip() throws {
        let directory = try TemporaryDirectory()
        let cache = WeatherCache(directory: directory.url)
        let dayStart = Fixtures.date(2026, 10, 29)
        let stored = entry(dayStart: dayStart, fetchedAt: Fixtures.date(2026, 10, 29, hour: 9), includesHourly: true)
        cache.store(stored, for: location, calendar: Fixtures.calendar)
        #expect(cache.entry(for: location, dayStart: dayStart, calendar: Fixtures.calendar) == stored)
        #expect(cache.entry(
            for: WeatherLocationKey(WeatherFixtures.osaka), dayStart: dayStart, calendar: Fixtures.calendar
        ) == nil)
    }

    @Test func entriesForADifferentDayStartAreIgnored() throws {
        let directory = try TemporaryDirectory()
        let cache = WeatherCache(directory: directory.url)
        let dayStart = Fixtures.date(2026, 10, 29)
        cache.store(entry(dayStart: dayStart, fetchedAt: dayStart), for: location, calendar: Fixtures.calendar)
        let shifted = dayStart.addingTimeInterval(3600)
        #expect(cache.entry(for: location, dayStart: shifted, calendar: Fixtures.calendar) == nil)
    }

    @Test func attributionRoundTrips() throws {
        let directory = try TemporaryDirectory()
        let cache = WeatherCache(directory: directory.url)
        #expect(cache.attribution == nil)
        cache.store(WeatherAttribution.placeholder)
        #expect(cache.attribution == .placeholder)
    }

    @Test func dailyOnlyEntriesDoNotCoverHourlyRequests() {
        let dayStart = Fixtures.date(2026, 10, 29)
        #expect(entry(dayStart: dayStart, fetchedAt: dayStart).covers(.daily))
        #expect(!entry(dayStart: dayStart, fetchedAt: dayStart).covers(.dailyAndHourly))
        #expect(entry(dayStart: dayStart, fetchedAt: dayStart, includesHourly: true).covers(.dailyAndHourly))
    }
}
