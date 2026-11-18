#if canImport(AlarmKit) && os(iOS)
import AlarmKit
import Foundation

public struct AlarmKitClient: AlarmSchedulingClient {
    public init() {}

    private var manager: AlarmManager {
        .shared
    }

    public func authorization() async -> NotificationAuthorization {
        NotificationAuthorization(manager.authorizationState)
    }

    public func requestAuthorization() async throws -> NotificationAuthorization {
        NotificationAuthorization(try await manager.requestAuthorization())
    }

    public func scheduledIdentifiers() async -> [UUID] {
        let alarms = (try? manager.alarms) ?? []
        return alarms.filter { $0.state.isWaitingToRing }.map(\.id)
    }

    public func heldIdentifiers() async -> [UUID] {
        let alarms = (try? manager.alarms) ?? []
        return alarms.filter { !$0.state.isWaitingToRing }.map(\.id)
    }

    public func schedule(_ request: AlarmRequest) async throws {
        _ = try await manager.schedule(id: request.id, configuration: request.alarmConfiguration)
    }

    public func cancel(identifiers: [UUID]) async {
        for identifier in identifiers {
            try? manager.cancel(id: identifier)
        }
    }
}

extension Alarm.State {
    /// Alarms that have rung, are snoozing or are paused aren't part of any plan, so a replan only cancels them
    /// once whatever they ring for is gone.
    var isWaitingToRing: Bool {
        switch self {
        case .scheduled: true
        case .countdown, .paused, .alerting: false
        @unknown default: false
        }
    }
}

extension NotificationAuthorization {
    init(_ state: AlarmManager.AuthorizationState) {
        switch state {
        case .notDetermined: self = .notDetermined
        case .authorized: self = .authorized
        case .denied: self = .denied
        @unknown default: self = .denied
        }
    }
}
#endif
