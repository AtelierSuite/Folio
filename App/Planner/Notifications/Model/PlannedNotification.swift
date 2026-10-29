import Foundation

public struct PlannedNotification: Identifiable, Sendable, Hashable {
    public let id: String
    public let fireDate: Date
    public let kind: CalendarItemKind
    public let reference: CalendarItemReference
    public let content: NotificationContent
    public let meeting: NotificationMeeting?
    public let category: NotificationCategory
    public let style: NotificationAlertStyle

    public init(_ candidate: NotificationCandidate, style: NotificationAlertStyle = .standard) {
        let category = NotificationCategory(candidate.kind)
        self.id = NotificationIdentifier.make(for: candidate, category: category, style: style)
        self.fireDate = candidate.fireDate
        self.kind = candidate.kind
        self.reference = candidate.reference
        self.content = candidate.content
        self.meeting = candidate.meeting
        self.category = category
        self.style = style
    }
}
