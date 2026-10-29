import Foundation

public struct NotificationCandidate: Sendable, Hashable {
    public let fireDate: Date
    public let kind: CalendarItemKind
    public let reference: CalendarItemReference
    public let content: NotificationContent

    public init(
        fireDate: Date,
        kind: CalendarItemKind,
        reference: CalendarItemReference,
        content: NotificationContent
    ) {
        self.fireDate = fireDate
        self.kind = kind
        self.reference = reference
        self.content = content
    }
}
