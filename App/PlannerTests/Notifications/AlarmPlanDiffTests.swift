#if canImport(AlarmKit) && os(iOS)
import AlarmKit
#endif
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

    @Test func synchronizerLeavesASnoozedAlarmAloneAndStopsOwningIt() async {
        let client = FakeAlarmClient()
        let defaults = UserDefaults(suiteName: "AlarmPlanDiffTests.\(UUID().uuidString)")!
        let ledger = AlarmLedger(key: "Test", defaults: defaults)
        let synchronizer = AlarmSynchronizer(client: client, ledger: ledger)
        let rung = request("rung", hours: 1)
        let next = request("next", hours: 2)
        _ = await synchronizer.synchronize([rung, next])
        client.snooze(rung.id)
        let outcome = await synchronizer.synchronize([next])
        #expect(outcome.failed.isEmpty)
        #expect(client.cancelCount == 0)
        #expect(client.snoozingIdentifiers == [rung.id])
        #expect(ledger.identifiers == [next.id])
    }

    #if canImport(AlarmKit) && os(iOS)
    @Test func onlyAlarmsWaitingToRingCountAsScheduled() {
        #expect(Alarm.State.scheduled.isWaitingToRing)
        #expect(!Alarm.State.countdown.isWaitingToRing)
        #expect(!Alarm.State.paused.isWaitingToRing)
        #expect(!Alarm.State.alerting.isWaitingToRing)
    }
    #endif

    @Test func reschedulesOwnedAlarmsWhoseSnoozeChanged() {
        let changed = request("changed", hours: 1)
        let unchanged = request("unchanged", hours: 2)
        let unrecorded = request("unrecorded", hours: 3)
        let diff = AlarmPlanDiff(
            planned: [changed, unchanged, unrecorded],
            scheduledIdentifiers: [changed.id, unchanged.id, unrecorded.id],
            ownedIdentifiers: [changed.id, unchanged.id, unrecorded.id],
            recordedActions: [changed.id: .snooze(60), unchanged.id: unchanged.secondaryAction]
        )
        #expect(diff.identifiersToCancel == [changed.id])
        #expect(diff.alarmsToSchedule == [changed])
    }

    @Test func synchronizerRecordsSecondaryActionsAndReschedulesChangedOnes() async {
        let client = FakeAlarmClient()
        let defaults = UserDefaults(suiteName: "AlarmPlanDiffTests.\(UUID().uuidString)")!
        let ledger = AlarmLedger(key: "Test", defaults: defaults)
        let synchronizer = AlarmSynchronizer(client: client, ledger: ledger)
        let original = request("standup", hours: 1)
        _ = await synchronizer.synchronize([original])
        #expect(ledger.secondaryActions == [original.id: original.secondaryAction])
        let snoozeChanged = AlarmRequest(
            id: original.id, fireDate: original.fireDate, title: original.title,
            tint: original.tint, item: original.item, secondaryAction: .snooze(20 * 60), source: original.source
        )
        _ = await synchronizer.synchronize([snoozeChanged])
        #expect(client.scheduledAlarms.map(\.secondaryAction) == [.snooze(20 * 60)])
        #expect(client.cancelCount == 1)
        #expect(ledger.identifiers == [original.id])
        #expect(ledger.secondaryActions == [original.id: .snooze(20 * 60)])
        _ = await synchronizer.synchronize([snoozeChanged])
        #expect(client.scheduleCount == 2)
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
