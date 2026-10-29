import Testing
@testable import Planner

struct MonthPagingTests {
    typealias Support = MonthTestSupport

    private let paging = MonthPaging(calendar: Support.calendar())

    @Test func monthsAroundADateAreConsecutiveMonthStarts() {
        let months = paging.months(around: Support.date(2026, 1, 31, 18), radius: 2)
        #expect(months == [
            Support.date(2025, 11, 1), Support.date(2025, 12, 1), Support.date(2026, 1, 1),
            Support.date(2026, 2, 1), Support.date(2026, 3, 1)
        ])
    }

    @Test func movingKeepsTheDayOfMonth() {
        let date = Support.date(2026, 10, 14)
        #expect(paging.date(date, movedToMonthOf: Support.date(2026, 12, 1)) == Support.date(2026, 12, 14))
        #expect(paging.date(date, movedToMonthOf: Support.date(2025, 3, 1)) == Support.date(2025, 3, 14))
    }

    @Test func movingClampsToTheLastDay() {
        let moved = paging.date(Support.date(2026, 1, 31), movedToMonthOf: Support.date(2026, 2, 1))
        #expect(moved == Support.date(2026, 2, 28))
    }

    @Test func sameMonthIgnoresTheDay() {
        #expect(paging.isSameMonth(Support.date(2026, 10, 1), Support.date(2026, 10, 31, 23)))
        #expect(!paging.isSameMonth(Support.date(2026, 10, 31), Support.date(2026, 11, 1)))
    }
}
