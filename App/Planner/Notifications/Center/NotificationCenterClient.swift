import Foundation

public protocol NotificationCenterClient: Sendable {
    func authorization() async -> NotificationAuthorization
    func requestAuthorization() async throws -> Bool
    func pendingIdentifiers() async -> [String]
    func add(_ notification: PlannedNotification, now: Date) async throws
    func removePending(withIdentifiers identifiers: [String]) async
}
