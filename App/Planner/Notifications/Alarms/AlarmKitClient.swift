#if canImport(AlarmKit) && os(iOS)
import AlarmKit
import Foundation
import SwiftUI

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

    public func schedule(_ alarm: PlannedNotification, identifier: UUID) async throws {
        let alert = AlarmPresentation.Alert(title: LocalizedStringResource(stringLiteral: alarm.content.title))
        let attributes = AlarmAttributes<FolioAlarmMetadata>(
            presentation: AlarmPresentation(alert: alert),
            metadata: FolioAlarmMetadata(alarm),
            tintColor: .accentColor
        )
        let configuration = AlarmManager.AlarmConfiguration<FolioAlarmMetadata>.alarm(
            schedule: .fixed(alarm.fireDate),
            attributes: attributes
        )
        _ = try await manager.schedule(id: identifier, configuration: configuration)
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
