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

    @Test func expandedTimeSpellsOutTheDuration() throws {
        let event = NotificationFixtures.event("Review", start: start, hours: 1.5)
        let time = try #require(formatter.content(for: event, firingAt: start).time)
        #expect(time == "9:00 ~ 10:30 (1 hour 30 minutes)")
    }

    @Test func expandedTimeLeavesOutEmptyUnits() throws {
        let event = NotificationFixtures.event("Workshop", start: start, hours: 2)
        let time = try #require(formatter.content(for: event, firingAt: start).time)
        #expect(time.hasSuffix("(2 hours)"))
    }

    @Test func expandedTimeDatesAnEndOnAnotherDay() throws {
        let event = NotificationFixtures.event("Flight", start: start, hours: 20)
        let time = try #require(formatter.content(for: event, firingAt: start).time)
        #expect(time == "9:00 ~ 30 Oct 5:00 (20 hours)")
    }

    @Test func expandedTimeCountsTheDaysOfAMultiDayEvent() throws {
        let day = Fixtures.date(2026, 10, 29)
        let event = NotificationFixtures.event("Trip", start: day, hours: 72, isAllDay: true)
        let time = try #require(formatter.content(for: event, firingAt: day).time)
        #expect(time == "29 Oct ~ 31 Oct (3 days)")
    }

    @Test func singleAllDayEventHasNoDuration() {
        let day = Fixtures.date(2026, 10, 29)
        let event = NotificationFixtures.event("Holiday", start: day, hours: 24, isAllDay: true)
        #expect(formatter.content(for: event, firingAt: day).time == NotificationContentFormatter.allDayText)
    }

    @Test func collapsedBodyKeepsItsShortTime() {
        let event = NotificationFixtures.event("Review", start: start, hours: 1.5)
        #expect(!formatter.content(for: event, firingAt: start).body.contains("minutes"))
    }

    @Test func alarmTitleAddsTheStartTime() {
        let event = NotificationFixtures.event("Standup", start: start, location: "Room 4")
        #expect(formatter.content(for: event, firingAt: start).alarmTitle == "Standup · 9:00")
        let dayBefore = formatter.content(for: event, firingAt: start.addingTimeInterval(-86_400)).alarmTitle
        #expect(dayBefore.hasPrefix("Standup · "))
        #expect(dayBefore.contains("29"))
        let day = Fixtures.date(2026, 10, 29)
        let allDay = NotificationFixtures.event("Holiday", start: day, hours: 24, isAllDay: true)
        #expect(formatter.content(for: allDay, firingAt: start).alarmTitle == "Holiday")
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
