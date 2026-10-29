import Foundation

public enum NotificationCategory: String, Sendable, CaseIterable {
    case event = "folio.event"
    case reminder = "folio.reminder"

    public init(_ kind: CalendarItemKind) {
        switch kind {
        case .event: self = .event
        case .reminder: self = .reminder
        }
    }
}
