import Foundation

public struct NotificationPlan: Sendable, Equatable {
    public let notifications: [PlannedNotification]
    public let alarms: [PlannedNotification]
    /// The alarm-style alerts that still exist, including those that rang a short while ago.
    public let liveAlarmSources: Set<String>

    public init(
        notifications: [PlannedNotification],
        alarms: [PlannedNotification],
        liveAlarmSources: Set<String> = []
    ) {
        self.notifications = notifications
        self.alarms = alarms
        self.liveAlarmSources = liveAlarmSources
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
