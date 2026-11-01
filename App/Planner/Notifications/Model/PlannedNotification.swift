import Foundation

public struct PlannedNotification: Identifiable, Sendable, Hashable {
    public let id: String
    public let fireDate: Date
    public let kind: CalendarItemKind
    public let reference: CalendarItemReference
    public let content: NotificationContent
    public let meeting: NotificationMeeting?
    public let place: NotificationPlace?
    public let category: NotificationCategory
    public let style: NotificationAlertStyle
    public let sound: NotificationSound

    public init(
        _ candidate: NotificationCandidate,
        style: NotificationAlertStyle = .standard,
        sound: NotificationSound = .system
    ) {
        let category = NotificationCategory(
            candidate.kind, hasMeeting: candidate.meeting != nil, hasPlace: candidate.place != nil
        )
        self.id = NotificationIdentifier.make(for: candidate, category: category, style: style, sound: sound)
        self.fireDate = candidate.fireDate
        self.kind = candidate.kind
        self.reference = candidate.reference
        self.content = candidate.content
        self.meeting = candidate.meeting
        self.place = candidate.place
        self.category = category
        self.style = style
        self.sound = sound
    }

    public var categoryIdentifier: String {
        category.identifier(joining: meeting?.link.provider)
    }
}
