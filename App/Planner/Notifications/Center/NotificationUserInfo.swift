import Foundation

public enum NotificationUserInfo {
    static let kindKey = "kind"
    static let referenceKey = "reference"
    static let fireDateKey = "fireDate"
    static let meetingKey = "meeting"

    static func make(for notification: PlannedNotification) -> [String: Any] {
        var userInfo: [String: Any] = [
            kindKey: notification.kind.rawValue,
            fireDateKey: notification.fireDate.timeIntervalSince1970
        ]
        if let data = try? JSONEncoder().encode(notification.reference) {
            userInfo[referenceKey] = data
        }
        if let meeting = notification.meeting, let data = try? JSONEncoder().encode(meeting) {
            userInfo[meetingKey] = data
        }
        userInfo.merge(make(for: notification.place)) { _, new in new }
        return userInfo
    }

    public static func kind(from userInfo: [AnyHashable: Any]) -> CalendarItemKind? {
        (userInfo[kindKey] as? String).flatMap(CalendarItemKind.init(rawValue:))
    }

    public static func reference(from userInfo: [AnyHashable: Any]) -> CalendarItemReference? {
        guard let data = userInfo[referenceKey] as? Data else { return nil }
        return try? JSONDecoder().decode(CalendarItemReference.self, from: data)
    }

    public static func meeting(from userInfo: [AnyHashable: Any]) -> NotificationMeeting? {
        guard let data = userInfo[meetingKey] as? Data else { return nil }
        return try? JSONDecoder().decode(NotificationMeeting.self, from: data)
    }

    public static func fireDate(from userInfo: [AnyHashable: Any]) -> Date? {
        (userInfo[fireDateKey] as? TimeInterval).map(Date.init(timeIntervalSince1970:))
    }
}
