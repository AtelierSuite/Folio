import Foundation

extension NotificationCategory {
    public var actions: [NotificationAction] {
        switch self {
        case .event: [.snoozeShort, .snoozeLong, .openNote]
        case .eventWithMeeting: [.joinMeeting, .snoozeShort, .snoozeLong, .openNote]
        case .eventWithPlace: [.directions, .snoozeShort, .snoozeLong, .openNote]
        case .eventWithMeetingAndPlace: [.joinMeeting, .directions, .snoozeShort, .snoozeLong, .openNote]
        case .reminder: [.markDone, .snoozeShort, .snoozeLong, .openNote]
        }
    }
}
