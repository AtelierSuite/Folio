import Foundation
import Testing
@testable import Planner

struct CalendarPageStepTests {
    typealias Support = TimelineTestSupport

    @Test func dayStepMovesOneDayEitherWay() {
        let calendar = Support.calendar()
        let start = Support.date(2026, 10, 29)
        #expect(CalendarPageStep.day.date(from: start, toward: .forward, in: calendar) == Support.date(2026, 10, 30))
        #expect(CalendarPageStep.day.date(from: start, toward: .backward, in: calendar) == Support.date(2026, 10, 28))
    }

    @Test func weekStepMovesSevenDays() {
        let calendar = Support.calendar()
        let start = Support.date(2026, 10, 29)
        #expect(CalendarPageStep.week.date(from: start, toward: .forward, in: calendar) == Support.date(2026, 11, 5))
        #expect(CalendarPageStep.week.date(from: start, toward: .backward, in: calendar) == Support.date(2026, 10, 22))
    }

    @Test func dayStepLandsOnStartOfDayAcrossDaylightSavingChange() {
        let calendar = Support.calendar()
        let start = Support.date(2026, 10, 31)
        let next = CalendarPageStep.day.date(from: start, toward: .forward, in: calendar)
        #expect(next == Support.date(2026, 11, 1))
        #expect(CalendarPageStep.day.date(from: next, toward: .forward, in: calendar) == Support.date(2026, 11, 2))
    }

    @Test func stepValueMultipliesTheMove() {
        let calendar = Support.calendar()
        let step = CalendarPageStep(component: .day, value: 3)
        let moved = step.date(from: Support.date(2026, 10, 29), toward: .forward, in: calendar)
        #expect(moved == Support.date(2026, 11, 1))
    }

    @Test func monthStepClampsToTheLastDay() {
        let calendar = Support.calendar()
        let next = CalendarPageStep.month.date(from: Support.date(2026, 1, 31), toward: .forward, in: calendar)
        #expect(next == Support.date(2026, 2, 28))
    }
}
