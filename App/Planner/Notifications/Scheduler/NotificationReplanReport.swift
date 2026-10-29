import Foundation

public struct NotificationReplanReport: Sendable, Equatable {
    public let date: Date
    public let budget: Int
    public let scheduledCount: Int
    public let pendingCount: Int
    public let addedCount: Int
    public let removedCount: Int
    public let alarmCount: Int
    public let nextFireDate: Date?
}
