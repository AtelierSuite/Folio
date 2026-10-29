import Foundation

public struct NotificationCandidate: Sendable, Hashable {
    public let fireDate: Date
    public let kind: CalendarItemKind
    public let reference: CalendarItemReference
    public let content: NotificationContent
}
