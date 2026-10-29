import Foundation
import Testing
@testable import Planner

struct CalendarSameDayTests {
    private func calendar(_ identifier: String) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: identifier) ?? .gmt
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, in calendar: Calendar) throws -> Date {
        try #require(calendar.date(from: DateComponents(year: year, month: month, day: day)))
    }

    @Test func movingWestKeepsTheSelectedDay() throws {
        let tokyo = calendar("Asia/Tokyo")
        let newYork = calendar("America/New_York")
        let selected = try date(2026, 10, 29, in: tokyo)
        let moved = newYork.startOfSameDay(as: selected, in: tokyo)
        #expect(moved == (try date(2026, 10, 29, in: newYork)))
        #expect(newYork.startOfDay(for: selected) != moved)
    }

    @Test func movingEastKeepsTheSelectedDay() throws {
        let losAngeles = calendar("America/Los_Angeles")
        let auckland = calendar("Pacific/Auckland")
        let selected = try date(2026, 3, 1, in: losAngeles)
        #expect(auckland.startOfSameDay(as: selected, in: losAngeles) == (try date(2026, 3, 1, in: auckland)))
    }

    @Test func sameTimeZoneIsUnchanged() throws {
        let london = calendar("Europe/London")
        let selected = try date(2026, 10, 25, in: london)
        #expect(london.startOfSameDay(as: selected, in: london) == selected)
    }
}
