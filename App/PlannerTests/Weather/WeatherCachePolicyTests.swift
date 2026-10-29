import Foundation
import Testing
@testable import Planner

struct WeatherCachePolicyTests {
    private let policy = WeatherCachePolicy()
    private let day = DateInterval(start: Fixtures.date(2026, 10, 29), duration: 86400)

    private func entry(fetchedAt: Date) -> WeatherCacheEntry {
        WeatherCacheEntry(
            day: WeatherDay(dayStart: day.start, daily: nil, hourly: []), fetchedAt: fetchedAt, includesHourly: true
        )
    }

    @Test func forecastsExpireAfterAnHour() {
        let fetched = Fixtures.date(2026, 10, 29, hour: 9)
        #expect(policy.isFresh(entry(fetchedAt: fetched), dayEnd: day.end, now: fetched.addingTimeInterval(3599)))
        #expect(!policy.isFresh(entry(fetchedAt: fetched), dayEnd: day.end, now: fetched.addingTimeInterval(3600)))
    }

    @Test func entriesFromTheFutureAreStale() {
        let fetched = Fixtures.date(2026, 10, 29, hour: 9)
        #expect(!policy.isFresh(entry(fetchedAt: fetched), dayEnd: day.end, now: fetched.addingTimeInterval(-60)))
    }

    @Test func daysFetchedAfterTheyEndedNeverExpire() {
        let fetched = day.end.addingTimeInterval(60)
        let muchLater = fetched.addingTimeInterval(365 * 86400)
        #expect(policy.isFresh(entry(fetchedAt: fetched), dayEnd: day.end, now: muchLater))
    }

    @Test func fetchesTenDaysAheadAndBackToAugust2021() {
        let now = Fixtures.date(2026, 10, 29, hour: 15)
        let calendar = Fixtures.calendar
        let tenthDay = DateInterval(start: Fixtures.date(2026, 11, 7), duration: 86400)
        let eleventhDay = DateInterval(start: Fixtures.date(2026, 11, 8), duration: 86400)
        #expect(policy.canFetch(tenthDay, now: now, calendar: calendar))
        #expect(!policy.canFetch(eleventhDay, now: now, calendar: calendar))
        let firstHistoricalDay = DateInterval(start: Fixtures.date(2021, 8, 1), duration: 86400)
        let dayBeforeHistory = DateInterval(start: Fixtures.date(2021, 7, 31), duration: 86400)
        #expect(policy.canFetch(firstHistoricalDay, now: now, calendar: calendar))
        #expect(!policy.canFetch(dayBeforeHistory, now: now, calendar: calendar))
    }
}
