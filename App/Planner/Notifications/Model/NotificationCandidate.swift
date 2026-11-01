import Foundation

public struct NotificationCandidate: Sendable, Hashable {
    public let fireDate: Date
    public let kind: CalendarItemKind
    public let reference: CalendarItemReference
    public let content: NotificationContent
    public let meeting: NotificationMeeting?
    public let place: NotificationPlace?
    public let color: PlannerColor?
    public let imageURL: URL?

    public init(
        fireDate: Date,
        kind: CalendarItemKind,
        reference: CalendarItemReference,
        content: NotificationContent,
        meeting: NotificationMeeting? = nil,
        place: NotificationPlace? = nil,
        color: PlannerColor? = nil,
        imageURL: URL? = nil
    ) {
        self.fireDate = fireDate
        self.kind = kind
        self.reference = reference
        self.content = content
        self.meeting = meeting
        self.place = place
        self.color = color
        self.imageURL = imageURL
    }
}
