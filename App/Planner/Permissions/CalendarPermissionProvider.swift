import Foundation

@MainActor
public final class CalendarPermissionProvider: PermissionProvider {
    private let store: CalendarStore
    private let kind: CalendarItemKind

    public init(store: CalendarStore, kind: CalendarItemKind) {
        self.store = store
        self.kind = kind
    }

    public var cachedStatus: PermissionStatus? {
        PermissionStatus(authorization)
    }

    public func currentStatus() async -> PermissionStatus {
        await store.refreshAuthorizationIfChanged()
        return PermissionStatus(authorization)
    }

    public func requestAccess() async throws -> PermissionStatus {
        switch kind {
        case .event: try await store.requestFullAccessToEvents()
        case .reminder: try await store.requestFullAccessToReminders()
        }
        return PermissionStatus(authorization)
    }

    private var authorization: CalendarAuthorizationStatus {
        switch kind {
        case .event: store.eventAuthorization
        case .reminder: store.reminderAuthorization
        }
    }
}
