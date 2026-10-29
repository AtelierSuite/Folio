import Foundation

@MainActor
public final class AlarmPermissionProvider: PermissionProvider {
    private let client: any AlarmSchedulingClient

    public init(client: (any AlarmSchedulingClient)? = nil) {
        self.client = client ?? DefaultAlarmClient.make(capabilities: .current)
    }

    public func currentStatus() async -> PermissionStatus {
        PermissionStatus(await client.authorization())
    }

    public func requestAccess() async throws -> PermissionStatus {
        PermissionStatus(try await client.requestAuthorization())
    }
}

extension PermissionStatus {
    public init(_ authorization: NotificationAuthorization) {
        switch authorization {
        case .notDetermined: self = .notDetermined
        case .denied: self = .denied
        case .authorized: self = .granted
        }
    }
}
