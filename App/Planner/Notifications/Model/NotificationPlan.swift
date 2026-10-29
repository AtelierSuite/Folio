import Foundation

public struct NotificationPlan: Sendable, Equatable {
    public let notifications: [PlannedNotification]
    public let alarms: [PlannedNotification]

    public init(notifications: [PlannedNotification], alarms: [PlannedNotification]) {
        self.notifications = notifications
        self.alarms = alarms
    }

    public static let empty = NotificationPlan(notifications: [], alarms: [])

    public var nextFireDate: Date? {
        [notifications.first?.fireDate, alarms.first?.fireDate].compactMap { $0 }.min()
    }
}
