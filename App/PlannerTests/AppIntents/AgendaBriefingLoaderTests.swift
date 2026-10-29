import Foundation
import Testing
@testable import Planner

struct AgendaBriefingLoaderTests {
    private let now = IntentTestSupport.now

    private func loader(events: [CalendarEvent] = [], reminders: [ReminderItem] = []) throws -> AgendaBriefingLoader {
        AgendaBriefingLoader(
            source: FakeCalendarDataSource(events: events, reminders: reminders),
            visibilityStorage: try IntentTestSupport.visibilityStorage(),
            calendar: Fixtures.calendar
        )
    }

    @Test func upNextIsTheOngoingEventThenTheNextTwo() async throws {
        let allDay = CalendarEvent(
            reference: Fixtures.reference(external: "holiday", local: "holiday", title: "Holiday"),
            calendarIdentifier: "work",
            title: "Holiday",
            startDate: Fixtures.date(2026, 10, 29),
            endDate: Fixtures.date(2026, 10, 30),
            isAllDay: true
        )
        let ongoing = IntentTestSupport.event("Workshop", start: Fixtures.date(2026, 10, 29, hour: 9), hours: 2)
        let following = (12...14).map { hour in
            IntentTestSupport.event("Call \(hour)", start: Fixtures.date(2026, 10, 29, hour: hour))
        }
        let briefing = try await loader(events: [allDay, ongoing] + following).upNext(at: now)

        #expect(briefing.events == [ongoing] + following.prefix(2))
        #expect(briefing.dialog.contains("Workshop"))
    }

    @Test func upNextSaysWhenThereIsNothingLeft() async throws {
        let finished = IntentTestSupport.event("Breakfast", start: Fixtures.date(2026, 10, 29, hour: 7))

        let briefing = try await loader(events: [finished]).upNext(at: now)

        #expect(briefing.events.isEmpty)
        #expect(briefing.dialog == AgendaDialogText.nothingNext())
    }

    @Test func todayListsTheDaysEventsAndOpenRemindersDueToday() async throws {
        let breakfast = IntentTestSupport.event("Breakfast", start: Fixtures.date(2026, 10, 29, hour: 7))
        let dinner = IntentTestSupport.event("Dinner", start: Fixtures.date(2026, 10, 29, hour: 19))
        let tomorrow = IntentTestSupport.event("Flight", start: Fixtures.date(2026, 10, 30, hour: 8))
        let dueToday = Fixtures.reminder(local: "Pay rent", due: Fixtures.date(2026, 10, 29, hour: 17))
        let dueLater = Fixtures.reminder(local: "Renew passport", due: Fixtures.date(2026, 11, 20))

        let briefing = try await loader(events: [dinner, tomorrow, breakfast], reminders: [dueLater, dueToday])
            .today(at: now)

        #expect(briefing.events == [breakfast, dinner])
        #expect(briefing.reminders == [dueToday])
        #expect(briefing.dialog.contains("Breakfast"))
        #expect(briefing.dialog.contains("Pay rent"))
        #expect(!briefing.dialog.contains("Flight"))
    }

    @Test func todaySaysWhenTheCalendarIsClear() async throws {
        let briefing = try await loader().today(at: now)

        #expect(briefing.dialog == AgendaDialogText.todayClear())
    }

    @Test func nextMeetingIsTheLinkedMeetingStartingClosestToNow() async throws {
        let startedLongAgo = IntentTestSupport.event(
            "Offsite", start: Fixtures.date(2026, 10, 29, hour: 8), hours: 4, notes: "https://zoom.us/j/1"
        )
        let noLink = IntentTestSupport.event("Coffee", start: now.addingTimeInterval(300))
        let soon = IntentTestSupport.event(
            "Standup", start: now.addingTimeInterval(600), location: "https://meet.google.com/abc-defg-hij"
        )
        let loader = try loader(events: [startedLongAgo, noLink, soon])

        #expect(await loader.nextMeeting(at: now) == soon)
        #expect(EventEntity(soon).meetingLink?.host() == "meet.google.com")
    }

    @Test func noNextMeetingWithoutLinks() async throws {
        let coffee = IntentTestSupport.event("Coffee", start: now.addingTimeInterval(300))

        #expect(try await loader(events: [coffee]).nextMeeting(at: now) == nil)
    }
}
