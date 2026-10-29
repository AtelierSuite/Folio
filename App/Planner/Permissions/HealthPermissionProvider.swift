import Foundation

/// HealthKit never says whether read access was denied, so after the prompt the status stays `.unknown`.
@MainActor
public final class HealthPermissionProvider: PermissionProvider {
    private let source: any SleepDataSource

    public init(source: any SleepDataSource) {
        self.source = source
    }

    public func currentStatus() async -> PermissionStatus {
        switch await source.authorizationRequestStatus() {
        case .shouldRequest: .notDetermined
        case .requested: .unknown
        case .unavailable: .unavailable
        }
    }

    public func requestAccess() async throws -> PermissionStatus {
        try await source.requestAuthorization()
        return await currentStatus()
    }
}
