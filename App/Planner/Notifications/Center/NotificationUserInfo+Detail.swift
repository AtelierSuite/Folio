import Foundation

extension NotificationUserInfo {
    static let statusKey = "status"
    static let timeKey = "time"
    static let colorKey = "color"
    static let originKey = "origin"

    static func make(for content: NotificationContent) -> [String: Any] {
        var userInfo: [String: Any] = [:]
        userInfo[statusKey] = content.status
        userInfo[timeKey] = content.time
        userInfo[colorKey] = content.color.flatMap { try? JSONEncoder().encode($0) }
        userInfo[originKey] = content.origin.flatMap { try? JSONEncoder().encode($0) }
        return userInfo
    }

    public static func status(from userInfo: [AnyHashable: Any]) -> String? {
        userInfo[statusKey] as? String
    }

    public static func time(from userInfo: [AnyHashable: Any]) -> String? {
        userInfo[timeKey] as? String
    }

    public static func color(from userInfo: [AnyHashable: Any]) -> PlannerColor? {
        guard let data = userInfo[colorKey] as? Data else { return nil }
        return try? JSONDecoder().decode(PlannerColor.self, from: data)
    }

    public static func origin(from userInfo: [AnyHashable: Any]) -> CalendarOrigin? {
        guard let data = userInfo[originKey] as? Data else { return nil }
        return try? JSONDecoder().decode(CalendarOrigin.self, from: data)
    }
}
