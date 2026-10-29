import Foundation
import Testing
@testable import Planner

struct CacheWindowPolicyTests {
    private let policy = CacheWindowPolicy(paddingWeeks: 2, calendar: Fixtures.calendar)

    @Test func padsWholeDaysByWeeks() {
        let visible = DateInterval(
            start: Fixtures.date(2026, 10, 29, hour: 9),
            end: Fixtures.date(2026, 10, 30, hour: 9)
        )
        let window = policy.window(around: visible)
        #expect(window.start == Fixtures.date(2026, 10, 15))
        #expect(window.end == Fixtures.date(2026, 11, 14))
    }

    @Test func keepsMidnightEndOnSameDay() {
        let visible = DateInterval(start: Fixtures.date(2026, 10, 29), end: Fixtures.date(2026, 10, 30))
        let window = policy.window(around: visible)
        #expect(window.end == Fixtures.date(2026, 11, 13))
    }
}
