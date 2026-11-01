import Foundation

public protocol AlarmSchedulingClient: Sendable {
    func authorization() async -> NotificationAuthorization
    func requestAuthorization() async throws -> NotificationAuthorization
    func scheduledIdentifiers() async -> [UUID]
    func schedule(_ request: AlarmRequest) async throws
    func cancel(identifiers: [UUID]) async
}
