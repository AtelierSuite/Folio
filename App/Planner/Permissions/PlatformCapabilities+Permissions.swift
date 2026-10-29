import Foundation

extension PlatformCapabilities {
    public func supports(permission: PermissionKind) -> Bool {
        guard let feature = permission.requiredFeature else { return true }
        return supports(feature)
    }
}
