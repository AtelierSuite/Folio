import Foundation

public struct AlarmPlanDiff: Sendable, Equatable {
    public let identifiersToCancel: [UUID]
    public let alarmsToSchedule: [AlarmRequest]
    public let plannedIdentifiers: Set<UUID>

    /// `heldIdentifiers` are alarms that have rung and are ringing, snoozing or paused;
    /// owned ones are cancelled unless they're in `retainedIdentifiers`.
    public init(
        planned: [AlarmRequest],
        scheduledIdentifiers: [UUID],
        ownedIdentifiers: Set<UUID>,
        heldIdentifiers: [UUID] = [],
        retainedIdentifiers: Set<UUID> = []
    ) {
        let plannedIdentifiers = Set(planned.map(\.id))
        let scheduled = Set(scheduledIdentifiers)
        let abandoned = Set(heldIdentifiers).subtracting(retainedIdentifiers)
        identifiersToCancel = scheduled.union(abandoned).intersection(ownedIdentifiers).subtracting(plannedIdentifiers)
            .sorted { $0.uuidString < $1.uuidString }
        alarmsToSchedule = planned.filter { !scheduled.contains($0.id) }
        self.plannedIdentifiers = plannedIdentifiers
    }

    public var isEmpty: Bool {
        identifiersToCancel.isEmpty && alarmsToSchedule.isEmpty
    }
}
