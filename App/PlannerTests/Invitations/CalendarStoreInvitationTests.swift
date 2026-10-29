import Foundation
import Testing
@testable import Planner

@MainActor
struct CalendarStoreInvitationTests {
    private let today = DateInterval(start: Fixtures.date(2026, 10, 29), end: Fixtures.date(2026, 10, 30))

    private func makeStore(source: FakeCalendarDataSource, defaults: UserDefaults) -> CalendarStore {
        CalendarStore(
            source: source,
            policy: CacheWindowPolicy(paddingWeeks: 1, calendar: Fixtures.calendar),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults)
        )
    }

    private func makeDefaults() throws -> UserDefaults {
        try #require(UserDefaults(suiteName: "CalendarStoreInvitationTests.\(UUID().uuidString)"))
    }

    private func makeSource() -> FakeCalendarDataSource {
        FakeCalendarDataSource(
            events: [
                InvitationFixtures.invitation(
                    local: "declined", start: Fixtures.date(2026, 10, 29, hour: 9), userStatus: .declined
                ),
                InvitationFixtures.invitation(
                    local: "pending", start: Fixtures.date(2026, 10, 29, hour: 11), userStatus: .pending
                ),
                InvitationFixtures.invitation(
                    local: "hidden", calendarIdentifier: "work",
                    start: Fixtures.date(2026, 10, 29, hour: 13), userStatus: .pending
                )
            ],
            calendars: [Fixtures.plannerCalendar("calendar-1"), Fixtures.plannerCalendar("work")]
        )
    }

    @Test func hidingDeclinedEventsFiltersAndPersists() async throws {
        let defaults = try makeDefaults()
        let source = makeSource()
        let store = makeStore(source: source, defaults: defaults)
        #expect(await store.events(in: today).map(\.title) == ["declined", "pending", "hidden"])

        store.setHidesDeclinedEvents(true)
        #expect(store.contentRevision == 1)
        #expect(await store.events(in: today).map(\.title) == ["pending", "hidden"])
        #expect(makeStore(source: source, defaults: defaults).hidesDeclinedEvents)

        store.setHidesDeclinedEvents(false)
        #expect(await store.events(in: today).count == 3)
    }

    @Test func pendingInvitationsSkipHiddenCalendars() async throws {
        let store = makeStore(source: makeSource(), defaults: try makeDefaults())
        #expect(await store.pendingInvitations(from: Fixtures.date(2026, 10, 29)).map(\.title) == ["pending", "hidden"])

        store.setVisible(false, for: Fixtures.plannerCalendar("work"))
        #expect(await store.pendingInvitations(from: Fixtures.date(2026, 10, 29)).map(\.title) == ["pending"])
    }
}
