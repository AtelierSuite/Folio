import Foundation

public struct AlarmSynchronizer: Sendable {
    public struct Outcome: Sendable, Equatable {
        public let scheduledCount: Int
        public let failed: [AlarmRequest]
    }

    let client: any AlarmSchedulingClient
    let ledger: AlarmLedger

    public init(client: any AlarmSchedulingClient, ledger: AlarmLedger) {
        self.client = client
        self.ledger = ledger
    }

    /// Makes this ledger's alarms match `requests`, returning the ones AlarmKit refused, such as past its limit.
    public func synchronize(_ requests: [AlarmRequest]) async -> Outcome {
        let scheduled = await client.scheduledIdentifiers()
        let diff = AlarmPlanDiff(
            planned: requests, scheduledIdentifiers: scheduled, ownedIdentifiers: ledger.identifiers
        )
        await client.cancel(identifiers: diff.identifiersToCancel)
        var live = Set(scheduled).intersection(diff.plannedIdentifiers)
        var failed: [AlarmRequest] = []
        for request in diff.alarmsToSchedule {
            if (try? await client.schedule(request)) != nil {
                live.insert(request.id)
            } else {
                failed.append(request)
            }
        }
        ledger.identifiers = live
        return Outcome(scheduledCount: live.count, failed: failed)
    }
}
