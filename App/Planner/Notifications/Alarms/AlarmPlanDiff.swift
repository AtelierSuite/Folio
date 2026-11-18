import Foundation

public struct AlarmPlanDiff: Sendable, Equatable {
    public let identifiersToCancel: [UUID]
    public let alarmsToSchedule: [AlarmRequest]
    public let plannedIdentifiers: Set<UUID>
    public let changedIdentifiers: Set<UUID>

    /// `heldIdentifiers` are alarms that have rung and are ringing, snoozing or paused;
    /// owned ones are cancelled unless they're in `retainedIdentifiers`. AlarmKit can't edit an alarm in place, so an
    /// owned alarm waiting to ring whose recorded secondary action differs from the planned one, such as after the
    /// snooze time changed, is cancelled and scheduled again.
    public init(
        planned: [AlarmRequest],
        scheduledIdentifiers: [UUID],
        ownedIdentifiers: Set<UUID>,
        heldIdentifiers: [UUID] = [],
        retainedIdentifiers: Set<UUID> = [],
        recordedActions: [UUID: AlarmSecondaryAction] = [:]
    ) {
        let plannedIdentifiers = Set(planned.map(\.id))
        let scheduled = Set(scheduledIdentifiers)
        let abandoned = Set(heldIdentifiers).subtracting(retainedIdentifiers)
        let ownedScheduled = scheduled.intersection(ownedIdentifiers)
        let changedIdentifiers = Set(planned.filter { request in
            guard ownedScheduled.contains(request.id), let recorded = recordedActions[request.id] else { return false }
            return recorded != request.secondaryAction
        }.map(\.id))
        identifiersToCancel = scheduled.union(abandoned).intersection(ownedIdentifiers).subtracting(plannedIdentifiers)
            .union(changedIdentifiers)
            .sorted { $0.uuidString < $1.uuidString }
        alarmsToSchedule = planned.filter { !scheduled.contains($0.id) || changedIdentifiers.contains($0.id) }
        self.plannedIdentifiers = plannedIdentifiers
        self.changedIdentifiers = changedIdentifiers
    }

    public var isEmpty: Bool {
        identifiersToCancel.isEmpty && alarmsToSchedule.isEmpty
    }
}
