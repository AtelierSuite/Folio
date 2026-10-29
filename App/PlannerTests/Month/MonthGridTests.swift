import Foundation
import Testing
@testable import Planner

struct MonthGridTests {
    typealias Support = MonthTestSupport

    @Test func sundayFirstLocaleStartsRowsOnSunday() {
        let grid = Support.grid(2026, 10, calendar: Support.calendar(locale: "en_US"))
        #expect(grid.days.first?.date == Support.date(2026, 9, 27))
        #expect(grid.days.last?.date == Support.date(2026, 10, 31))
        #expect(grid.weeks.count == 5)
        #expect(grid.orderedWeekdays == [1, 2, 3, 4, 5, 6, 7])
    }

    @Test func mondayFirstLocaleStartsRowsOnMonday() {
        let grid = Support.grid(2026, 10, calendar: Support.calendar(locale: "de_DE"))
        #expect(grid.days.first?.date == Support.date(2026, 9, 28))
        #expect(grid.days.last?.date == Support.date(2026, 11, 1))
        #expect(grid.orderedWeekdays == [2, 3, 4, 5, 6, 7, 1])
    }

    @Test func saturdayFirstWeekdayStartsRowsOnSaturday() {
        let grid = Support.grid(2026, 10, calendar: Support.calendar(locale: "en_US", firstWeekday: 7))
        #expect(grid.days.first?.date == Support.date(2026, 9, 26))
        #expect(grid.orderedWeekdays == [7, 1, 2, 3, 4, 5, 6])
        #expect(grid.weeks.count == 6)
    }

    @Test(arguments: ["en_US", "en_GB", "ja_JP", "fr_FR", "ar_EG"], 1...7)
    func everyRowStartsOnTheFirstWeekdayAndCoversTheMonth(locale: String, firstWeekday: Int) {
        let calendar = Support.calendar(locale: locale, firstWeekday: firstWeekday)
        for month in 1...12 {
            let grid = Support.grid(2026, month, calendar: calendar)
            #expect(grid.weeks.allSatisfy { $0.days.count == 7 })
            #expect(grid.weeks.allSatisfy { calendar.component(.weekday, from: $0.days[0].date) == firstWeekday })
            let monthLength = calendar.range(of: .day, in: .month, for: grid.month.start)?.count
            #expect(grid.days.filter(\.isInMonth).count == monthLength)
            #expect(grid.days.filter(\.isInMonth).first?.dayOfMonth == 1)
            #expect((4...6).contains(grid.weeks.count))
            #expect(!grid.weeks[0].days.allSatisfy { !$0.isInMonth })
            #expect(!grid.weeks[grid.weeks.count - 1].days.allSatisfy { !$0.isInMonth })
        }
    }

    @Test func leadingAndTrailingDaysAreOutsideTheMonth() {
        let grid = Support.grid(2026, 10, calendar: Support.calendar(locale: "de_DE"))
        #expect(grid.days.prefix(3).map(\.dayOfMonth) == [28, 29, 30])
        #expect(grid.days.prefix(3).allSatisfy { !$0.isInMonth })
        #expect(grid.days[3].isInMonth && grid.days[3].dayOfMonth == 1)
        #expect(grid.days.last?.dayOfMonth == 1 && grid.days.last?.isInMonth == false)
    }

    @Test func februaryStartingOnFirstWeekdayFitsFourRows() {
        let grid = Support.grid(2026, 2, calendar: Support.calendar(locale: "en_US"))
        #expect(grid.weeks.count == 4)
        #expect(grid.days.allSatisfy { $0.isInMonth })
    }

    @Test func daysFollowEachOtherAcrossDaylightSavingChanges() {
        let grid = Support.grid(2026, 11, calendar: Support.calendar(locale: "en_US"))
        #expect(zip(grid.days, grid.days.dropFirst()).allSatisfy { $0.interval.end == $1.interval.start })
        #expect(grid.day(containing: Support.date(2026, 11, 1, 23))?.dayOfMonth == 1)
        #expect(grid.span?.end == Support.date(2026, 12, 6))
    }

    @Test func weekNumbersFollowISO8601() {
        let sundayFirst = Support.grid(2026, 1, calendar: Support.calendar(locale: "en_US"))
        #expect(sundayFirst.weeks.map(\.weekNumber) == [1, 2, 3, 4, 5])
        let mondayFirst = Support.grid(2027, 1, calendar: Support.calendar(locale: "de_DE"))
        #expect(mondayFirst.weeks.map(\.weekNumber) == [53, 1, 2, 3, 4])
        let december = Support.grid(2026, 12, calendar: Support.calendar(locale: "de_DE"))
        #expect(december.weeks.last?.weekNumber == 53)
    }

    @Test func weekNumberUsesTheISOWeekCoveringMostOfTheRow() {
        let saturdayFirst = Support.grid(2026, 1, calendar: Support.calendar(locale: "en_US", firstWeekday: 7))
        #expect(saturdayFirst.weeks[0].days[0].date == Support.date(2025, 12, 27))
        #expect(saturdayFirst.weeks[0].weekNumber == 1)
    }
}
