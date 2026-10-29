import Foundation
import Testing
@testable import Planner

struct PendingInvitationsTests {
    @Test func keepsPendingInvitationsSortedByStart() {
        let events = [
            InvitationFixtures.invitation(local: "later", start: Fixtures.date(2026, 11, 2), userStatus: .pending),
            InvitationFixtures.invitation(local: "accepted", start: Fixtures.date(2026, 10, 30), userStatus: .accepted),
            InvitationFixtures.invitation(local: "own", start: Fixtures.date(2026, 10, 30), userStatus: nil),
            InvitationFixtures.invitation(local: "declined", start: Fixtures.date(2026, 10, 31), userStatus: .declined),
            InvitationFixtures.invitation(local: "sooner", start: Fixtures.date(2026, 10, 30), userStatus: .unknown)
        ]
        #expect(events.pendingInvitations().map(\.title) == ["sooner", "later"])
    }

    @Test func showsOneOccurrencePerSeries() {
        let events = [
            InvitationFixtures.invitation(
                local: "weekly", external: "series", start: Fixtures.date(2026, 11, 5), userStatus: .pending
            ),
            InvitationFixtures.invitation(
                local: "weekly", external: "series", start: Fixtures.date(2026, 10, 29), userStatus: .pending
            )
        ]
        let invitations = events.pendingInvitations()
        #expect(invitations.count == 1)
        #expect(invitations.first?.startDate == Fixtures.date(2026, 10, 29))
    }
}
