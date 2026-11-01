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
        return alarms.filter { $0.state != .alerting }.map(\.id)
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
