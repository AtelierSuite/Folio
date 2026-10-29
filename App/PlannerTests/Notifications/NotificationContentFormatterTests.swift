import Foundation
import Testing
@testable import Planner

struct NotificationContentFormatterTests {
    private let formatter = NotificationFixtures.formatter
    private let start = Fixtures.date(2026, 10, 29, hour: 9)

    @Test func timedEventShowsTimeAndLocation() {
        let event = NotificationFixtures.event("Standup", start: start, location: " Room 4 ")
        let content = formatter.content(for: event, firingAt: start.addingTimeInterval(-600))
        #expect(content.title == "Standup")
        #expect(content.body.contains("9:00"))
        #expect(content.body.contains("10:00"))
        #expect(content.body.hasSuffix(" · Room 4"))
        #expect(!content.body.contains("2026"))
    }

    @Test func eventOnAnotherDayIncludesTheDate() {
        let event = NotificationFixtures.event("Dentist", start: start)
        let content = formatter.content(for: event, firingAt: start.addingTimeInterval(-86_400))
        #expect(content.body.contains("29"))
        #expect(content.body.contains("9:00"))
    }

    @Test func allDayEventSaysAllDay() {
        let day = Fixtures.date(2026, 10, 29)
        let event = NotificationFixtures.event("Holiday", start: day, hours: 24, isAllDay: true)
        let sameDay = formatter.content(for: event, firingAt: day.addingTimeInterval(3600)).body
        #expect(sameDay == NotificationContentFormatter.allDayText)
        let dayBefore = formatter.content(for: event, firingAt: day.addingTimeInterval(-3600)).body
        #expect(dayBefore.hasPrefix("29"))
        #expect(dayBefore.hasSuffix(" · \(NotificationContentFormatter.allDayText)"))
    }

    @Test func eventWithoutLocationHasNoSeparator() {
        let content = formatter.content(for: NotificationFixtures.event("Focus", start: start), firingAt: start)
        #expect(!content.body.contains("·"))
    }

    @Test func reminderShowsDueTime() {
        let reminder = NotificationFixtures.reminder("Call", due: start)
        #expect(formatter.content(for: reminder, firingAt: start).body.hasSuffix("9:00"))
        let undated = NotificationFixtures.reminder("Someday", due: nil, alarms: [.absolute(date: start)])
        #expect(formatter.content(for: undated, firingAt: start).body.isEmpty)
        let dateOnly = NotificationFixtures.reminder("Invoice", due: Fixtures.date(2026, 10, 30), hasDueTime: false)
        #expect(formatter.content(for: dateOnly, firingAt: start).body.contains("30"))
    }
}
