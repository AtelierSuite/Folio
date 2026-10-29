import Foundation
import Testing
@testable import Planner

struct NotificationPlanDiffTests {
    private let now = NotificationFixtures.now
    private let planner = NotificationFixtures.planner()

    private func plan(_ events: [CalendarEvent]) -> [PlannedNotification] {
        planner.plan(events: events, reminders: [], after: now, budget: 60)
    }

    private func events(_ count: Int) -> [CalendarEvent] {
        (0..<count).map { index in
            NotificationFixtures.event("event-\(index)", start: NotificationFixtures.hours(Double(index) + 1))
        }
    }

    @Test func addsOnlyWhatIsMissingAndKeepsForeignRequests() {
        let planned = plan(events(3))
        let stale = "\(NotificationIdentifier.prefix)event.old@1.abc"
        let diff = NotificationPlanDiff(
            planned: planned,
            pendingIdentifiers: [planned[0].id, stale, "folio.snooze.1", "other"]
        )
        #expect(diff.identifiersToRemove == [stale])
        #expect(diff.notificationsToAdd == Array(planned.dropFirst()))
    }

    @Test func replanningAnUnchangedPlanIsANoOp() {
        let planned = plan([NotificationFixtures.event("meeting", start: NotificationFixtures.hours(2))])
        #expect(NotificationPlanDiff(planned: planned, pendingIdentifiers: planned.map(\.id)).isEmpty)
    }

    @Test func movedEventReplacesItsRequest() {
        let original = plan([NotificationFixtures.event("meeting", start: NotificationFixtures.hours(2))])
        let moved = plan([NotificationFixtures.event("meeting", start: NotificationFixtures.hours(3))])
        let diff = NotificationPlanDiff(planned: moved, pendingIdentifiers: original.map(\.id))
        #expect(diff.identifiersToRemove == original.map(\.id))
        #expect(diff.notificationsToAdd == moved)
    }

    @Test func deletedEventRemovesItsRequest() {
        let original = plan([
            NotificationFixtures.event("kept", start: NotificationFixtures.hours(2)),
            NotificationFixtures.event("deleted", start: NotificationFixtures.hours(4))
        ])
        let remaining = plan([NotificationFixtures.event("kept", start: NotificationFixtures.hours(2))])
        let diff = NotificationPlanDiff(planned: remaining, pendingIdentifiers: original.map(\.id))
        #expect(diff.identifiersToRemove == [original[1].id])
        #expect(diff.notificationsToAdd.isEmpty)
    }

    @Test func emptyPlanClearsEveryOwnedRequest() {
        let original = plan([NotificationFixtures.event("meeting", start: NotificationFixtures.hours(2))])
        let diff = NotificationPlanDiff(planned: [], pendingIdentifiers: original.map(\.id) + ["foreign"])
        #expect(diff.identifiersToRemove == original.map(\.id))
    }

    @Test func soonerItemPushesTheLatestOutWhenFull() {
        let full = plan(events(60))
        let newcomer = NotificationFixtures.event("newcomer", start: NotificationFixtures.hours(0.5))
        let withNewcomer = plan(events(60) + [newcomer])
        let diff = NotificationPlanDiff(planned: withNewcomer, pendingIdentifiers: full.map(\.id))
        #expect(diff.identifiersToRemove == [full[59].id])
        #expect(diff.notificationsToAdd.map(\.content.title) == ["newcomer"])
        #expect(full.count - diff.identifiersToRemove.count + diff.notificationsToAdd.count == 60)
    }
}
