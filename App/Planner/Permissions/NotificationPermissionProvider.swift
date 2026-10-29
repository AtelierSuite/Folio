import Foundation
import UserNotifications

@MainActor
public final class NotificationPermissionProvider: PermissionProvider {
    private let makeCenter: () -> UNUserNotificationCenter

    public init(center makeCenter: @escaping () -> UNUserNotificationCenter = { .current() }) {
        self.makeCenter = makeCenter
    }

    public func currentStatus() async -> PermissionStatus {
        PermissionStatus(await makeCenter().notificationSettings().authorizationStatus)
    }

    public func requestAccess() async throws -> PermissionStatus {
        _ = try await makeCenter().requestAuthorization(options: [.alert, .sound, .badge])
        return await currentStatus()
    }
}

extension PermissionStatus {
    public init(_ status: UNAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notDetermined
        case .denied: self = .denied
        case .authorized, .provisional: self = .granted
        #if os(iOS)
        case .ephemeral: self = .granted
        #endif
        @unknown default: self = .unknown
        }
    }
}
