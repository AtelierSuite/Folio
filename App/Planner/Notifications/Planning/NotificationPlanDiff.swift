import Foundation

public struct NotificationPlanDiff: Sendable, Equatable {
    public let identifiersToRemove: [String]
    public let notificationsToAdd: [PlannedNotification]

    public init(planned: [PlannedNotification], pendingIdentifiers: [String]) {
        let plannedIdentifiers = Set(planned.map(\.id))
        let ownedPending = Set(pendingIdentifiers.filter(NotificationIdentifier.isOwned))
        identifiersToRemove = ownedPending.subtracting(plannedIdentifiers).sorted()
        notificationsToAdd = planned.filter { !ownedPending.contains($0.id) }
    }

    public var isEmpty: Bool {
        identifiersToRemove.isEmpty && notificationsToAdd.isEmpty
    }
}
