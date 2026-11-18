import Foundation

public protocol AlarmSchedulingClient: Sendable {
    func authorization() async -> NotificationAuthorization
    func requestAuthorization() async throws -> NotificationAuthorization
    func scheduledIdentifiers() async -> [UUID]
    /// Alarms that have rung and are still ringing, snoozing or paused.
    func heldIdentifiers() async -> [UUID]
    func schedule(_ request: AlarmRequest) async throws
    func cancel(identifiers: [UUID]) async
}
