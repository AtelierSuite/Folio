import Foundation
import Testing
@testable import Planner

struct AlarmPlanDiffTests {
    private func alarm(_ local: String, hours: Double) -> PlannedNotification {
        let event = NotificationFixtures.event(local, start: NotificationFixtures.hours(hours))
        let candidate = NotificationCandidate(
            fireDate: event.startDate, kind: .event, reference: event.reference,
            content: NotificationContent(title: local, body: "")
        )
        return PlannedNotification(candidate, style: .alarm)
    }

    @Test func identifiersAreStableAndDependOnStyle() {
        let first = alarm("standup", hours: 1)
        #expect(AlarmIdentifier.make(for: first) == AlarmIdentifier.make(for: alarm("standup", hours: 1)))
        #expect(AlarmIdentifier.make(for: first) != AlarmIdentifier.make(for: first.restyled(.timeSensitive)))
        #expect(AlarmIdentifier.make(for: first) != AlarmIdentifier.make(for: alarm("standup", hours: 2)))
    }

    @Test func schedulesNewCancelsStaleOwnedAndKeepsForeignAlarms() {
        let kept = alarm("kept", hours: 1)
        let added = alarm("added", hours: 2)
        let stale = AlarmIdentifier.make(for: alarm("stale", hours: 3))
        let foreign = UUID()
        let diff = AlarmPlanDiff(
            planned: [kept, added],
            scheduledIdentifiers: [AlarmIdentifier.make(for: kept), stale, foreign],
            ownedIdentifiers: [AlarmIdentifier.make(for: kept), stale]
        )
        #expect(diff.alarmsToSchedule == [added])
        #expect(diff.identifiersToCancel == [stale])
    }

    @Test func matchingPlanIsEmpty() {
        let planned = [alarm("one", hours: 1), alarm("two", hours: 2)]
        let identifiers = planned.map(AlarmIdentifier.make(for:))
        let diff = AlarmPlanDiff(
            planned: planned, scheduledIdentifiers: identifiers, ownedIdentifiers: Set(identifiers)
        )
        #expect(diff.isEmpty)
    }
}
