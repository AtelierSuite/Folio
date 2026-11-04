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

    @Test func hiddenInvitationLeavesTheListAndCalendarAndPersists() async throws {
        let defaults = try makeDefaults()
        let source = makeSource()
        let store = makeStore(source: source, defaults: defaults)
        let start = Fixtures.date(2026, 10, 29)
        let invitation = try #require(await store.pendingInvitations(from: start).first)

        store.setHidden(true, invitation: invitation)
        #expect(store.contentRevision == 1)
        #expect(await store.pendingInvitations(from: start).map(\.title) == ["hidden"])
        #expect(await store.events(in: today).map(\.title) == ["declined", "hidden"])
        #expect(await store.hiddenInvitations(from: start).map(\.title) == ["pending"])
        #expect(await store.invitationCounts(from: start) == InvitationCounts(pending: 1, hidden: 1))

        let relaunched = makeStore(source: source, defaults: defaults)
        #expect(await relaunched.pendingInvitations(from: start).map(\.title) == ["hidden"])

        store.setHidden(false, invitation: invitation)
        #expect(await store.pendingInvitations(from: start).map(\.title) == ["pending", "hidden"])
        #expect(await store.hiddenInvitations(from: start).isEmpty)
    }

    @Test func invitationsStayReachableWhenEveryOneIsHidden() async throws {
        let store = makeStore(source: makeSource(), defaults: try makeDefaults())
        let start = Fixtures.date(2026, 10, 29)
        for invitation in await store.pendingInvitations(from: start) {
            store.setHidden(true, invitation: invitation)
        }
        let counts = await store.invitationCounts(from: start)
        #expect(counts == InvitationCounts(pending: 0, hidden: 2))
        #expect(counts.hasInvitations)
        #expect(!InvitationCounts().hasInvitations)
    }

    @Test func hiddenInvitationStaysHiddenWhenItResurfaces() async throws {
        let start = Fixtures.date(2026, 10, 29, hour: 9)
        func source(_ status: ParticipantStatus) -> FakeCalendarDataSource {
            FakeCalendarDataSource(
                events: [
                    InvitationFixtures.invitation(local: "resent", external: "series", start: start, userStatus: status)
                ],
                calendars: [Fixtures.plannerCalendar("calendar-1")]
            )
        }
        let defaults = try makeDefaults()
        let declined = makeStore(source: source(.declined), defaults: defaults)
        let invitation = try #require(await declined.events(in: today).first)
        declined.setHidden(true, invitation: invitation)
        #expect(await declined.events(in: today).isEmpty)

        let resurfaced = makeStore(source: source(.pending), defaults: defaults)
        #expect(await resurfaced.pendingInvitations(from: start).isEmpty)
        #expect(await resurfaced.events(in: today).isEmpty)

        let accepted = makeStore(source: source(.accepted), defaults: defaults)
        #expect(await accepted.events(in: today).map(\.title) == ["resent"])
        #expect(await accepted.hiddenInvitations(from: start).isEmpty)
    }

    @Test func pendingInvitationsSkipHiddenCalendars() async throws {
        let store = makeStore(source: makeSource(), defaults: try makeDefaults())
        #expect(await store.pendingInvitations(from: Fixtures.date(2026, 10, 29)).map(\.title) == ["pending", "hidden"])

        store.setVisible(false, for: Fixtures.plannerCalendar("work"))
        #expect(await store.pendingInvitations(from: Fixtures.date(2026, 10, 29)).map(\.title) == ["pending"])
    }
}
