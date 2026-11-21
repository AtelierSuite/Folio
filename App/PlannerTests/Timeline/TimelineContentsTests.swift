import Foundation
import Testing
@testable import Planner

struct TimelineContentsTests {
    private let days = TimelineDays(startingOn: Fixtures.date(2026, 11, 4), count: 1, calendar: Fixtures.calendar)

    private func copy(_ local: String, calendarIdentifier: String) -> CalendarEvent {
        let start = Fixtures.date(2026, 11, 4, hour: 9)
        return CalendarEvent(
            reference: Fixtures.reference(
                external: "external-\(local)", local: local, calendarIdentifier: calendarIdentifier
            ),
            calendarIdentifier: calendarIdentifier,
            title: "Team Sync",
            startDate: start,
            endDate: start.addingTimeInterval(3600)
        )
    }

    @Test func duplicateEventsBecomeOneEntry() async {
        let engine = TimelineLayoutEngine(days: days)
        let contents = await engine.contents(
            events: [copy("work", calendarIdentifier: "work"), copy("home", calendarIdentifier: "home")],
            otherEntries: []
        )
        #expect(contents.entries.count == 1)
        #expect(contents.entries.first?.duplicateCount == 2)
        #expect(contents.layout.timedPlacements.count == 1)
    }

    @Test func otherEntriesAreLaidOutAfterEvents() async {
        let engine = TimelineLayoutEngine(days: days)
        let reminder = TimelineEntry(
            id: "reminder:local-2",
            title: "Call",
            start: Fixtures.date(2026, 11, 4, hour: 14),
            end: Fixtures.date(2026, 11, 4, hour: 14).addingTimeInterval(TimelineEntry.reminderDuration),
            isAllDay: false,
            timeZone: Fixtures.calendar.timeZone,
            color: TimelineTestSupport.gray,
            kind: .reminder
        )
        let event = Fixtures.event(local: "lunch", start: Fixtures.date(2026, 11, 4, hour: 12))
        let contents = await engine.contents(events: [event], otherEntries: [reminder])
        #expect(contents.entries.map(\.id) == [event.id, reminder.id])
        #expect(contents.layout == engine.layout(contents.entries))
        #expect(contents.layout.days == days)
    }
}
