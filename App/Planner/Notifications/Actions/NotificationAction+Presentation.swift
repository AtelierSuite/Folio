import Foundation

extension NotificationAction {
    public var title: String {
        switch self {
        case .joinMeeting: String(localized: "Action.JoinMeeting", table: "NotificationActions", bundle: #bundle)
        case .directions: String(localized: "Action.Directions", table: "NotificationActions", bundle: #bundle)
        case .markDone: String(localized: "Action.MarkDone", table: "NotificationActions", bundle: #bundle)
        case .snoozeShort: String(localized: "Action.Snooze5", table: "NotificationActions", bundle: #bundle)
        case .snoozeLong: String(localized: "Action.Snooze15", table: "NotificationActions", bundle: #bundle)
        case .openNote: String(localized: "Action.OpenNote", table: "NotificationActions", bundle: #bundle)
        }
    }

    public var systemImage: String {
        switch self {
        case .joinMeeting: "video"
        case .directions: "arrow.triangle.turn.up.right.diamond"
        case .markDone: "checkmark.circle"
        case .snoozeShort, .snoozeLong: "zzz"
        case .openNote: "note.text"
        }
    }
}
