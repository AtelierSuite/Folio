import Foundation
import UserNotifications

public struct NotificationResponseRouter: Sendable {
    public var now: Date

    public init(now: Date) {
        self.now = now
    }

    public func outcome(actionIdentifier: String, userInfo: [AnyHashable: Any]) -> NotificationResponseOutcome? {
        guard let item = NotificationUserInfo.item(from: userInfo) else { return nil }
        let meeting = NotificationUserInfo.meeting(from: userInfo)
        if actionIdentifier == UNNotificationDefaultActionIdentifier {
            let joinableURL = meeting.flatMap { $0.isJoinable(at: now) ? $0.link.url : nil }
            return .open(.item(item.destination, meetingURL: joinableURL))
        }
        guard let action = NotificationAction(rawValue: actionIdentifier) else { return nil }
        return outcome(for: action, item: item, meeting: meeting, place: NotificationUserInfo.place(from: userInfo))
    }

    private func outcome(
        for action: NotificationAction,
        item: NotificationItem,
        meeting: NotificationMeeting?,
        place: NotificationPlace?
    ) -> NotificationResponseOutcome? {
        switch action {
        case .joinMeeting:
            return .open(meeting.map { .url($0.link.url) } ?? .item(item.destination, meetingURL: nil))
        case .directions:
            return .open(place?.directionsURL.map(NotificationRoute.url) ?? .item(item.destination, meetingURL: nil))
        case .markDone:
            return item.kind == .reminder ? .markDone(item) : nil
        case .snoozeShort, .snoozeLong:
            let duration = action.snoozeDuration ?? 0
            return .snooze(NotificationSnooze(item: item, fireDate: now.addingTimeInterval(duration)))
        case .openNote:
            switch item.kind {
            case .event: return .open(.note(.event(item.reference, date: item.date)))
            case .reminder: return .open(.note(.dailyNote(item.date)))
            }
        }
    }
}
