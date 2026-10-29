import Foundation

/// Alerts use a category per set of actions, since a category's actions are fixed when it's registered.
public enum NotificationCategory: String, Sendable, CaseIterable {
    case event = "folio.event"
    case eventWithMeeting = "folio.event.meeting"
    case eventWithPlace = "folio.event.place"
    case eventWithMeetingAndPlace = "folio.event.meeting.place"
    case reminder = "folio.reminder"

    public init(_ kind: CalendarItemKind, context: NotificationActionContext = .none) {
        switch (kind, context.meetingURL != nil, context.place != nil) {
        case (.reminder, _, _): self = .reminder
        case (.event, false, false): self = .event
        case (.event, true, false): self = .eventWithMeeting
        case (.event, false, true): self = .eventWithPlace
        case (.event, true, true): self = .eventWithMeetingAndPlace
        }
    }

    public var kind: CalendarItemKind {
        self == .reminder ? .reminder : .event
    }

    public var threadIdentifier: String {
        "folio.\(kind.rawValue)"
    }
}
