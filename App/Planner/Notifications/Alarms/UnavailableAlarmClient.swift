import Foundation

public struct UnavailableAlarmClient: AlarmSchedulingClient {
    public init() {}

    public func authorization() async -> NotificationAuthorization { .denied }
    public func requestAuthorization() async throws -> NotificationAuthorization { .denied }
    public func scheduledIdentifiers() async -> [UUID] { [] }
    public func schedule(_ request: AlarmRequest) async throws {}
    public func cancel(identifiers: [UUID]) async {}
}
