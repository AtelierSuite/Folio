import Contacts
import Foundation

@MainActor
public final class ContactsPermissionProvider: PermissionProvider {
    private let store = CNContactStore()

    public init() {}

    public var cachedStatus: PermissionStatus? {
        PermissionStatus(CNContactStore.authorizationStatus(for: .contacts))
    }

    public func currentStatus() async -> PermissionStatus {
        PermissionStatus(CNContactStore.authorizationStatus(for: .contacts))
    }

    public func requestAccess() async throws -> PermissionStatus {
        _ = try await store.requestAccess(for: .contacts)
        return await currentStatus()
    }
}

extension PermissionStatus {
    public init(_ status: CNAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notDetermined
        case .restricted: self = .restricted
        case .denied: self = .denied
        case .authorized, .limited: self = .granted
        @unknown default: self = .unknown
        }
    }
}
