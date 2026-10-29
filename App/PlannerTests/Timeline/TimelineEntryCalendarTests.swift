import Foundation
import Testing
@testable import Planner

struct TimelineEntryCalendarTests {
    private let start = Date(timeIntervalSinceReferenceDate: 800_000_000)

    private func reference(_ identifier: String) -> CalendarItemReference {
        CalendarItemReference(
            externalIdentifier: identifier,
            localIdentifier: identifier,
            calendarIdentifier: "calendar",
            title: identifier,
            startDate: start
        )
    }

    @Test func eventKeepsItsTimesColorAndReadOnlyFlag() {
        let event = CalendarEvent(
            reference: reference("event"),
            calendarIdentifier: "calendar",
            title: "Standup",
            startDate: start,
            endDate: start.addingTimeInterval(900),
            timeZone: TimeZone(identifier: "Asia/Tokyo"),
            color: PlannerColor(red: 0.5, green: 0.2, blue: 0.3),
            isReadOnly: true
        )
        let entry = TimelineEntry(event: event)
        #expect(entry.id == event.id)
        #expect(entry.start == event.startDate)
        #expect(entry.end == event.endDate)
        #expect(entry.timeZone == TimeZone(identifier: "Asia/Tokyo"))
        #expect(entry.color == TimelineColor(red: 0.5, green: 0.2, blue: 0.3))
        #expect(entry.isReadOnly)
        #expect(entry.kind == .event)
    }

    @Test func allDayEventIsFloating() {
        let event = CalendarEvent(
            reference: reference("holiday"),
            calendarIdentifier: "calendar",
            title: "Holiday",
            startDate: start,
            endDate: start.addingTimeInterval(86_400),
            isAllDay: true,
            timeZone: TimeZone(identifier: "Europe/London")
        )
        #expect(TimelineEntry(event: event).isFloating)
    }

    @Test func timedReminderGetsAShortSlot() throws {
        let reminder = ReminderItem(
            reference: reference("reminder"),
            listIdentifier: "list",
            title: "Call",
            dueDate: start,
            hasDueTime: true
        )
        let entry = try #require(TimelineEntry(reminder: reminder))
        #expect(entry.kind == .reminder)
        #expect(!entry.isAllDay)
        #expect(entry.end.timeIntervalSince(entry.start) == TimelineEntry.reminderDuration)
        #expect(entry.id != reminder.id)
    }

    @Test func dateOnlyReminderIsAllDay() throws {
        let reminder = ReminderItem(
            reference: reference("reminder"),
            listIdentifier: "list",
            title: "Pay rent",
            dueDate: start
        )
        #expect(try #require(TimelineEntry(reminder: reminder)).isAllDay)
    }

    @Test func undatedReminderHasNoEntry() {
        let reminder = ReminderItem(reference: reference("reminder"), listIdentifier: "list", title: "Someday")
        #expect(TimelineEntry(reminder: reminder) == nil)
    }
}
