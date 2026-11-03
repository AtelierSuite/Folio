import Foundation

public struct AlarmRequest: Sendable, Hashable, Identifiable {
    public let id: UUID
    public let fireDate: Date
    public let title: String
    public let tint: PlannerColor?
    /// `nil` for an alarm the user set on its own, not for an event or reminder.
    public let item: NotificationItem?
    public let secondaryAction: AlarmSecondaryAction

    public init(
        id: UUID,
        fireDate: Date,
        title: String,
        tint: PlannerColor?,
        item: NotificationItem?,
        secondaryAction: AlarmSecondaryAction
    ) {
        self.id = id
        self.fireDate = fireDate
        self.title = title
        self.tint = tint
        self.item = item
        self.secondaryAction = secondaryAction
    }

    public init(alert: PlannedNotification) {
        self.init(
            id: AlarmIdentifier.make(for: alert),
            fireDate: alert.fireDate,
            title: alert.content.alarmTitle,
            tint: alert.color,
            item: NotificationItem(kind: alert.kind, reference: alert.reference, fireDate: alert.fireDate),
            secondaryAction: .alertSnooze
        )
    }

    public var link: URL? {
        item.map { CalendarDeepLink.url(forEvent: $0.reference, startingAt: $0.date) }
    }
}
