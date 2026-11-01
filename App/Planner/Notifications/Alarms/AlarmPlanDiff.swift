import Foundation

public struct AlarmPlanDiff: Sendable, Equatable {
    public let identifiersToCancel: [UUID]
    public let alarmsToSchedule: [AlarmRequest]
    public let plannedIdentifiers: Set<UUID>

    public init(planned: [AlarmRequest], scheduledIdentifiers: [UUID], ownedIdentifiers: Set<UUID>) {
        let plannedIdentifiers = Set(planned.map(\.id))
        let scheduled = Set(scheduledIdentifiers)
        identifiersToCancel = scheduled.intersection(ownedIdentifiers).subtracting(plannedIdentifiers)
            .sorted { $0.uuidString < $1.uuidString }
        alarmsToSchedule = planned.filter { !scheduled.contains($0.id) }
        self.plannedIdentifiers = plannedIdentifiers
    }

    public var isEmpty: Bool {
        identifiersToCancel.isEmpty && alarmsToSchedule.isEmpty
    }
}
