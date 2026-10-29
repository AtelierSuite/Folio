import Foundation
import Testing
@testable import Planner

struct SearchDatePresetTests {
    private let now = Fixtures.date(2026, 10, 29, hour: 15)

    private func interval(_ preset: SearchDatePreset) -> DateInterval {
        preset.interval(around: now, calendar: Fixtures.calendar)
    }

    private func days(from start: Date, to end: Date) -> DateInterval {
        DateInterval(start: start, end: end)
    }

    @Test func presetsCoverWholeDays() {
        #expect(interval(.today) == days(from: Fixtures.date(2026, 10, 29), to: Fixtures.date(2026, 10, 30)))
        #expect(interval(.next7Days) == days(from: Fixtures.date(2026, 10, 29), to: Fixtures.date(2026, 11, 5)))
        #expect(interval(.next30Days).end == Fixtures.date(2026, 11, 28))
        #expect(interval(.past7Days) == days(from: Fixtures.date(2026, 10, 23), to: Fixtures.date(2026, 10, 30)))
        #expect(interval(.past30Days).start == Fixtures.date(2026, 9, 30))
    }

    @Test func searchRangeSpansMonthsAroundToday() {
        let range = SearchRange(monthsBack: 1, monthsAhead: 2).interval(around: now, calendar: Fixtures.calendar)
        #expect(range == DateInterval(start: Fixtures.date(2026, 9, 29), end: Fixtures.date(2026, 12, 30)))
        #expect(SearchRange(monthsBack: -3, monthsAhead: 0).monthsBack == 0)
    }
}
