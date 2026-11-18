import Foundation

public struct AlarmRequest: Sendable, Hashable, Identifiable {
    public let id: UUID
    public let fireDate: Date
    public let title: String
    public let tint: PlannerColor?
    /// `nil` for an alarm the user set on its own, not for an event or reminder.
    public let item: NotificationItem?
    public let secondaryAction: AlarmSecondaryAction
    /// What the alarm rings for, which stays the same when its time or wording changes.
    public let source: String

    public init(
        id: UUID,
        fireDate: Date,
        title: String,
        tint: PlannerColor?,
        item: NotificationItem?,
        secondaryAction: AlarmSecondaryAction,
        source: String? = nil
    ) {
        self.id = id
        self.fireDate = fireDate
        self.title = title
        self.tint = tint
        self.item = item
        self.secondaryAction = secondaryAction
        self.source = source ?? id.uuidString
    }

    public init(alert: PlannedNotification) {
        self.init(
            id: AlarmIdentifier.make(for: alert),
            fireDate: alert.fireDate,
            title: alert.content.alarmTitle,
            tint: alert.color,
            item: NotificationItem(kind: alert.kind, reference: alert.reference, fireDate: alert.fireDate),
            secondaryAction: .snooze,
            source: alert.alarmSource
        )
    }

    public var link: URL? {
        item.map { CalendarDeepLink.url(forEvent: $0.reference, startingAt: $0.date) }
    }
}

extension PlannedNotification {
    /// The alert the alarm rings for, unlike `id`, which also changes with the alert's wording.
    var alarmSource: String {
        "\(kind.rawValue).\(reference.storageKey)@\(Int(fireDate.timeIntervalSince1970.rounded(.down)))"
    }
}
