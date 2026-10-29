import Foundation
import Testing
@testable import Planner

struct WidgetSnapshotLoaderTests {
    private let now = Fixtures.date(2026, 10, 29, hour: 10)

    private func makeSource() -> FakeCalendarDataSource {
        FakeCalendarDataSource(
            events: [
                Fixtures.event(local: "work", calendarIdentifier: "work", start: Fixtures.date(2026, 10, 29, hour: 11)),
                Fixtures.event(local: "home", calendarIdentifier: "home", start: Fixtures.date(2026, 10, 29, hour: 18)),
                Fixtures.event(local: "next week", calendarIdentifier: "home", start: Fixtures.date(2026, 11, 5, hour: 9))
            ],
            reminders: [
                Fixtures.reminder(local: "errand", listIdentifier: "personal", due: now),
                Fixtures.reminder(local: "report", listIdentifier: "office", due: now)
            ]
        )
    }

    private func makeStorage(hidden: Set<String>) throws -> CalendarVisibilityStorage {
        let defaults = try #require(UserDefaults(suiteName: "WidgetSnapshotLoaderTests.\(UUID().uuidString)"))
        let storage = CalendarVisibilityStorage(defaults: defaults)
        storage.hiddenCalendarIdentifiers = hidden
        return storage
    }

    @Test func showsVisibleCalendarsByDefault() async throws {
        let loader = WidgetSnapshotLoader(source: makeSource(), visibilityStorage: try makeStorage(hidden: ["home", "office"]))
        let request = WidgetSnapshotRequest.upcoming(from: now, calendar: Fixtures.calendar, includesReminders: true)
        let snapshot = await loader.load(request, at: now)
        #expect(snapshot.events.map(\.title) == ["work"])
        #expect(snapshot.reminders.map(\.title) == ["errand"])
    }

    @Test func configuredCalendarsReplaceVisibility() async throws {
        let loader = WidgetSnapshotLoader(source: makeSource(), visibilityStorage: try makeStorage(hidden: ["home"]))
        let request = WidgetSnapshotRequest.upcoming(from: now, calendar: Fixtures.calendar, calendars: ["home"])
        let snapshot = await loader.load(request, at: now)
        #expect(snapshot.events.map(\.title) == ["home"])
        #expect(snapshot.reminders.isEmpty)
    }

    @Test func remindersRequestSkipsEvents() async throws {
        let loader = WidgetSnapshotLoader(source: makeSource(), visibilityStorage: try makeStorage(hidden: []))
        let snapshot = await loader.load(.reminders(lists: ["office"]), at: now)
        #expect(snapshot.events.isEmpty)
        #expect(snapshot.reminders.map(\.title) == ["report"])
    }

    @Test func reportsMissingAccess() async throws {
        let source = makeSource()
        source.setAuthorization(.denied, for: .event)
        let loader = WidgetSnapshotLoader(source: source, visibilityStorage: try makeStorage(hidden: []))
        let snapshot = await loader.load(.reminders(), at: now)
        #expect(!snapshot.canReadEvents)
        #expect(snapshot.canReadReminders)
    }

    @Test func monthRequestCoversTheWholeGrid() {
        let request = WidgetSnapshotRequest.month(containing: now, calendar: Fixtures.calendar)
        #expect(request.eventInterval == MonthGrid(containing: now, calendar: Fixtures.calendar).span)
    }
}
