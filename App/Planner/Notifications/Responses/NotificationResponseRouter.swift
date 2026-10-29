import Foundation
import UserNotifications

public struct NotificationResponseRouter: Sendable {
    /// Tapping a meeting's alert opens its link from this long before the meeting starts.
    public static let meetingLeadTime: TimeInterval = 60 * 60

    public var now: Date

    public init(now: Date) {
        self.now = now
    }

    public func outcome(actionIdentifier: String, userInfo: [AnyHashable: Any]) -> NotificationResponseOutcome? {
        guard let item = NotificationUserInfo.item(from: userInfo) else { return nil }
        let context = NotificationUserInfo.actionContext(from: userInfo)
        if actionIdentifier == UNNotificationDefaultActionIdentifier {
            return .open(.item(item.destination, meetingURL: joinableMeetingURL(for: item, context: context)))
        }
        guard let action = NotificationAction(rawValue: actionIdentifier) else { return nil }
        return outcome(for: action, item: item, context: context)
    }

    private func outcome(
        for action: NotificationAction,
        item: NotificationItem,
        context: NotificationActionContext
    ) -> NotificationResponseOutcome? {
        switch action {
        case .joinMeeting:
            return .open(context.meetingURL.map(NotificationRoute.url) ?? .item(item.destination, meetingURL: nil))
        case .directions:
            let directions = context.place?.directionsURL.map(NotificationRoute.url)
            return .open(directions ?? .item(item.destination, meetingURL: nil))
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

    private func joinableMeetingURL(for item: NotificationItem, context: NotificationActionContext) -> URL? {
        guard item.kind == .event, now >= item.date.addingTimeInterval(-Self.meetingLeadTime) else { return nil }
        return context.meetingURL
    }
}
