import Foundation
import Testing
@testable import Planner

struct AlarmPlanDiffTests {
    private func request(_ local: String, hours: Double) -> AlarmRequest {
        AlarmRequest(alert: alarm(local, hours: hours))
    }

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
        let kept = request("kept", hours: 1)
        let added = request("added", hours: 2)
        let stale = request("stale", hours: 3).id
        let foreign = UUID()
        let diff = AlarmPlanDiff(
            planned: [kept, added],
            scheduledIdentifiers: [kept.id, stale, foreign],
            ownedIdentifiers: [kept.id, stale]
        )
        #expect(diff.alarmsToSchedule == [added])
        #expect(diff.identifiersToCancel == [stale])
    }

    @Test func matchingPlanIsEmpty() {
        let planned = [request("one", hours: 1), request("two", hours: 2)]
        let identifiers = planned.map(\.id)
        let diff = AlarmPlanDiff(
            planned: planned, scheduledIdentifiers: identifiers, ownedIdentifiers: Set(identifiers)
        )
        #expect(diff.isEmpty)
    }

    @Test func synchronizerReportsRefusedAlarmsAndOnlyRecordsLiveOnes() async {
        let client = FakeAlarmClient()
        client.setLimit(1)
        let defaults = UserDefaults(suiteName: "AlarmPlanDiffTests.\(UUID().uuidString)")!
        let ledger = AlarmLedger(key: "Test", defaults: defaults)
        let first = request("first", hours: 1)
        let second = request("second", hours: 2)
        let outcome = await AlarmSynchronizer(client: client, ledger: ledger).synchronize([first, second])
        #expect(outcome.scheduledCount == 1)
        #expect(outcome.failed == [second])
        #expect(ledger.identifiers == [first.id])
    }

    @Test func requestUsesTheAlarmTitleAndColor() {
        let event = NotificationFixtures.event("standup", start: NotificationFixtures.hours(1))
        let candidate = NotificationCandidate(
            fireDate: event.startDate, kind: .event, reference: event.reference,
            content: NotificationContent(title: "standup", body: "", alarmTitle: "standup · 10:00"),
            color: .gray
        )
        let request = AlarmRequest(alert: PlannedNotification(candidate, style: .alarm))
        #expect(request.title == "standup · 10:00")
        #expect(request.tint == .gray)
        #expect(request.item?.reference == event.reference)
    }
}
