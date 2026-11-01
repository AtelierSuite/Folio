import Foundation

public struct NotificationPlan: Sendable, Equatable {
    public let notifications: [PlannedNotification]
    public let alarms: [PlannedNotification]

    public init(notifications: [PlannedNotification], alarms: [PlannedNotification]) {
        self.notifications = notifications
        self.alarms = alarms
    }

    public static let empty = NotificationPlan(notifications: [], alarms: [])

    func notifications(adding fallbacks: [PlannedNotification], budget: Int) -> [PlannedNotification] {
        guard !fallbacks.isEmpty else { return notifications }
        let merged = (notifications + fallbacks).sorted { ($0.fireDate, $0.id) < ($1.fireDate, $1.id) }
        return Array(merged.prefix(max(0, budget)))
    }

    public var nextFireDate: Date? {
        [notifications.first?.fireDate, alarms.first?.fireDate].compactMap { $0 }.min()
    }
}
