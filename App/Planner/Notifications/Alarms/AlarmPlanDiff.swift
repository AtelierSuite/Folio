import Foundation

public struct AlarmPlanDiff: Sendable, Equatable {
    public let identifiersToCancel: [UUID]
    public let alarmsToSchedule: [PlannedNotification]
    public let plannedIdentifiers: Set<UUID>

    public init(planned: [PlannedNotification], scheduledIdentifiers: [UUID], ownedIdentifiers: Set<UUID>) {
        let plannedByIdentifier = planned.map { (AlarmIdentifier.make(for: $0), $0) }
        let plannedIdentifiers = Set(plannedByIdentifier.map(\.0))
        let scheduled = Set(scheduledIdentifiers)
        identifiersToCancel = scheduled.intersection(ownedIdentifiers).subtracting(plannedIdentifiers)
            .sorted { $0.uuidString < $1.uuidString }
        alarmsToSchedule = plannedByIdentifier.filter { !scheduled.contains($0.0) }.map(\.1)
        self.plannedIdentifiers = plannedIdentifiers
    }

    public var isEmpty: Bool {
        identifiersToCancel.isEmpty && alarmsToSchedule.isEmpty
    }
}
