import Foundation

extension NotificationAction {
    public func title(snoozing durations: NotificationSnoozeDurations) -> String {
        guard let minutes = snoozeMinutes(in: durations) else { return title }
        let duration = NotificationSnoozeDurations.title(forMinutes: minutes)
        return String(localized: "Action.Snooze \(duration)", table: "NotificationActions", bundle: #bundle)
    }

    public var title: String {
        switch self {
        case .joinMeeting: String(localized: "Action.JoinMeeting", table: "NotificationActions", bundle: #bundle)
        case .directions: String(localized: "Action.Directions", table: "NotificationActions", bundle: #bundle)
        case .markDone: String(localized: "Action.MarkDone", table: "NotificationActions", bundle: #bundle)
        case .snoozeShort, .snoozeLong: title(snoozing: .standard)
        case .openNote: String(localized: "Action.OpenNote", table: "NotificationActions", bundle: #bundle)
        }
    }

    public func title(joining provider: MeetingProvider?, snoozing durations: NotificationSnoozeDurations) -> String {
        guard self == .joinMeeting, let provider else { return title(snoozing: durations) }
        return provider.joinTitle
    }

    public func systemImage(joining provider: MeetingProvider?) -> String {
        guard self == .joinMeeting, let provider else { return systemImage }
        return provider.systemImage
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
