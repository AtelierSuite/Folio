import Foundation

public struct AlarmSynchronizer: Sendable {
    public struct Outcome: Sendable, Equatable {
        public let scheduledCount: Int
        public let failed: [AlarmRequest]
    }

    /// How long after its time an alarm may keep snoozing before a replan no longer looks for what it rings for.
    public static let heldAlarmLookBack: TimeInterval = 12 * 3600

    let client: any AlarmSchedulingClient
    let ledger: AlarmLedger

    public init(client: any AlarmSchedulingClient, ledger: AlarmLedger) {
        self.client = client
        self.ledger = ledger
    }

    /// Makes this ledger's alarms match `requests`, returning the ones AlarmKit refused, such as past its limit.
    /// With `liveSources`, the sources that still exist, including those whose alarms have rung, a ringing,
    /// snoozed or paused alarm stays only while its source is live. Without it, such alarms are left alone.
    public func synchronize(_ requests: [AlarmRequest], liveSources: Set<String>? = nil) async -> Outcome {
        let scheduled = await client.scheduledIdentifiers()
        let held = liveSources == nil ? [] : await client.heldIdentifiers()
        let owned = ledger.identifiers
        let previousSources = ledger.sources
        let retained = Set(held).intersection(owned).filter { identifier in
            previousSources[identifier].map { liveSources?.contains($0) == true } ?? false
        }
        let diff = AlarmPlanDiff(
            planned: requests,
            scheduledIdentifiers: scheduled,
            ownedIdentifiers: owned,
            heldIdentifiers: held,
            retainedIdentifiers: retained,
            recordedActions: ledger.secondaryActions
        )
        await client.cancel(identifiers: diff.identifiersToCancel)
        var live = Set(scheduled).intersection(diff.plannedIdentifiers).subtracting(diff.changedIdentifiers)
        var failed: [AlarmRequest] = []
        for request in diff.alarmsToSchedule {
            if (try? await client.schedule(request)) != nil {
                live.insert(request.id)
            } else {
                failed.append(request)
            }
        }
        var sources = previousSources.filter { retained.contains($0.key) }
        var actions = ledger.secondaryActions.filter { retained.contains($0.key) }
        for request in requests where live.contains(request.id) {
            sources[request.id] = request.source
            actions[request.id] = request.secondaryAction
        }
        ledger.identifiers = live.union(retained)
        ledger.sources = sources
        ledger.secondaryActions = actions
        return Outcome(scheduledCount: live.count, failed: failed)
    }
}
