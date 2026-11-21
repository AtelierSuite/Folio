import Foundation

extension NotificationScheduler {
    /// Each add builds its thumbnail first, so they run side by side instead of one after another.
    @concurrent
    nonisolated static func add(
        _ notifications: [PlannedNotification],
        to center: any NotificationCenterClient
    ) async -> Int {
        await withTaskGroup(of: Bool.self) { group in
            for notification in notifications {
                group.addTask { (try? await center.add(notification)) != nil }
            }
            return await group.reduce(0) { count, isAdded in isAdded ? count + 1 : count }
        }
    }
}
