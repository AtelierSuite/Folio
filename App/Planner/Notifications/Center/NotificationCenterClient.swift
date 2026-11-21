import Foundation

public protocol NotificationCenterClient: Sendable {
    func authorization() async -> NotificationAuthorization
    func requestAuthorization() async throws -> Bool
    func pendingIdentifiers() async -> [String]
    @concurrent func add(_ notification: PlannedNotification) async throws
    func removePending(withIdentifiers identifiers: [String]) async
    func deliveredEndDates() async -> [String: Date]
    func removeDelivered(withIdentifiers identifiers: [String]) async
}
