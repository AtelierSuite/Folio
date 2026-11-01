import Foundation

public struct AlarmRequest: Sendable, Hashable, Identifiable {
    public let id: UUID
    public let fireDate: Date
    public let title: String
    public let tint: PlannerColor?
    public let item: NotificationItem

    public init(id: UUID, fireDate: Date, title: String, tint: PlannerColor?, item: NotificationItem) {
        self.id = id
        self.fireDate = fireDate
        self.title = title
        self.tint = tint
        self.item = item
    }

    public init(alert: PlannedNotification) {
        self.init(
            id: AlarmIdentifier.make(for: alert),
            fireDate: alert.fireDate,
            title: alert.content.alarmTitle,
            tint: alert.color,
            item: NotificationItem(kind: alert.kind, reference: alert.reference, fireDate: alert.fireDate)
        )
    }
}
