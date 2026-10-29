import Foundation

public struct PlannedNotification: Identifiable, Sendable, Hashable {
    public let id: String
    public let fireDate: Date
    public let kind: CalendarItemKind
    public let reference: CalendarItemReference
    public let content: NotificationContent
    public let category: NotificationCategory
    public let style: NotificationAlertStyle

    public init(
        fireDate: Date,
        kind: CalendarItemKind,
        reference: CalendarItemReference,
        content: NotificationContent,
        style: NotificationAlertStyle = .standard
    ) {
        let category = NotificationCategory(kind)
        self.id = NotificationIdentifier.make(
            kind: kind, reference: reference, fireDate: fireDate, content: content, category: category, style: style
        )
        self.fireDate = fireDate
        self.kind = kind
        self.reference = reference
        self.content = content
        self.category = category
        self.style = style
    }
}
