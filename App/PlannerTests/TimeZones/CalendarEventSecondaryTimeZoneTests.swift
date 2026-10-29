import Foundation
import Testing
@testable import Planner

struct CalendarEventSecondaryTimeZoneTests {
    private let tokyo = TimeZone(identifier: "Asia/Tokyo") ?? .gmt
    private let london = TimeZone(identifier: "Europe/London") ?? .gmt

    private func event(isAllDay: Bool = false, timeZone: TimeZone?) -> CalendarEvent {
        let start = Fixtures.date(2026, 10, 29, hour: 9)
        return CalendarEvent(
            reference: Fixtures.reference(),
            calendarIdentifier: "calendar-1",
            title: "Standup",
            startDate: start,
            endDate: start.addingTimeInterval(3600),
            isAllDay: isAllDay,
            timeZone: timeZone
        )
    }

    @Test func timedEventsShowTheSecondaryTime() {
        #expect(event(timeZone: london).showsTime(in: tokyo, comparedTo: london))
    }

    @Test func floatingEventsDoNot() {
        #expect(!event(timeZone: nil).showsTime(in: tokyo, comparedTo: london))
    }

    @Test func allDayEventsDoNot() {
        #expect(!event(isAllDay: true, timeZone: london).showsTime(in: tokyo, comparedTo: london))
    }

    @Test func sameOffsetAsTheSystemDoesNot() {
        let seoul = TimeZone(identifier: "Asia/Seoul") ?? .gmt
        #expect(!event(timeZone: tokyo).showsTime(in: seoul, comparedTo: tokyo))
    }
}
