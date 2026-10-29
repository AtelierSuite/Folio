import Foundation

@MainActor
public protocol PermissionProvider: AnyObject {
    var cachedStatus: PermissionStatus? { get }
    func currentStatus() async -> PermissionStatus
    func requestAccess() async throws -> PermissionStatus
}

extension PermissionProvider {
    public var cachedStatus: PermissionStatus? { nil }
}
