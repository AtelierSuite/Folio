import Foundation
import Testing
@testable import Planner

struct ItemConversionTests {
    private let calendar = Fixtures.calendar
    private let start = Fixtures.date(2026, 10, 29, hour: 9)

    @Test func timedEventBecomesAReminderDueWhenItStarts() {
        let event = EventDraft(
            title: "Dentist",
            calendarIdentifier: "work",
            startDate: start,
            endDate: start.addingTimeInterval(5400),
            alerts: [.minutesBefore(15)],
            location: EventLocation(title: "Clinic", address: "1 Main St"),
            url: URL(string: "https://example.com"),
            notes: "Bring card"
        )
        let reminder = event.convertedToReminder(listIdentifier: "list-1", calendar: calendar)
        #expect(reminder.title == "Dentist")
        #expect(reminder.listIdentifier == "list-1")
        #expect(reminder.dueDate == start)
        #expect(reminder.hasDueTime)
        #expect(reminder.alarms == [.relative(-900)])
        #expect(reminder.url == URL(string: "https://example.com"))
        #expect(reminder.notes == "Clinic\n1 Main St\n\nBring card")
    }

    @Test func allDayEventBecomesAReminderWithoutADueTime() {
        let day = Fixtures.date(2026, 10, 29)
        let event = EventDraft(
            title: "Holiday", calendarIdentifier: "work", startDate: day,
            endDate: Fixtures.date(2026, 10, 30), isAllDay: true, alerts: [EventAlert(offset: 9 * 3600)]
        )
        let reminder = event.convertedToReminder(listIdentifier: "list-1", calendar: calendar)
        #expect(reminder.dueDate == day)
        #expect(!reminder.hasDueTime)
        #expect(reminder.alarms == [.absolute(Fixtures.date(2026, 10, 29, hour: 9))])
    }

    @Test func repeatingEventKeepsItsRepeatWithACountTurnedIntoAnEndDate() {
        let event = EventDraft(
            title: "Standup", calendarIdentifier: "work", startDate: start, endDate: start.addingTimeInterval(900),
            recurrence: EventRecurrence(frequency: .weekly, interval: 2, end: .afterOccurrences(3))
        )
        let reminder = event.convertedToReminder(listIdentifier: "list-1", calendar: calendar)
        #expect(reminder.recurrence == ReminderRecurrence(
            frequency: .weekly, interval: 2, endDate: Fixtures.date(2026, 11, 26, hour: 9)
        ))
    }

    @Test func timedReminderBecomesAnHourLongEvent() {
        let reminder = ReminderDraft(
            title: "Call mum", listIdentifier: "list-1", dueDate: start, hasDueTime: true,
            recurrence: ReminderRecurrence(frequency: .monthly, endDate: Fixtures.date(2027, 1, 1)),
            alarms: [.relative(-300), .absolute(start.addingTimeInterval(-3600))],
            notes: "Birthday"
        )
        let event = reminder.convertedToEvent(calendarIdentifier: "work", calendar: calendar)
        #expect(event.title == "Call mum")
        #expect(event.calendarIdentifier == "work")
        #expect(event.startDate == start)
        #expect(event.endDate == start.addingTimeInterval(EventDraft.defaultDuration))
        #expect(!event.isAllDay)
        #expect(event.alerts == [.minutesBefore(5), .minutesBefore(60)])
        #expect(event.recurrence == EventRecurrence(frequency: .monthly, end: .onDate(Fixtures.date(2027, 1, 1))))
        #expect(event.notes == "Birthday")
    }

    @Test func reminderWithoutADueTimeBecomesAnAllDayEvent() {
        let reminder = ReminderDraft(title: "Pay rent", listIdentifier: "list-1", dueDate: start)
        let event = reminder.convertedToEvent(calendarIdentifier: "work", calendar: calendar)
        #expect(event.isAllDay)
        #expect(event.startDate == Fixtures.date(2026, 10, 29))
        #expect(event.endDate == Fixtures.date(2026, 10, 30))
    }

    @Test func undatedReminderBecomesAnAllDayEventToday() {
        let reminder = ReminderDraft(title: "Someday", listIdentifier: "list-1")
        let event = reminder.convertedToEvent(calendarIdentifier: "work", today: start, calendar: calendar)
        #expect(event.isAllDay)
        #expect(event.startDate == Fixtures.date(2026, 10, 29))
        #expect(event.recurrence == nil)
    }
}
