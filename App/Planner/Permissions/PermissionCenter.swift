import Foundation
import Observation

@MainActor
@Observable
public final class PermissionCenter {
    public private(set) var statuses: [PermissionKind: PermissionStatus] = [:]

    @ObservationIgnored private let providers: [PermissionKind: any PermissionProvider]
    @ObservationIgnored private let capabilities: PlatformCapabilities

    public init(providers: [PermissionKind: any PermissionProvider], capabilities: PlatformCapabilities) {
        self.providers = providers
        self.capabilities = capabilities
        for kind in availableKinds {
            statuses[kind] = providers[kind]?.cachedStatus
        }
    }

    public var availableKinds: [PermissionKind] {
        PermissionKind.allCases.filter(isAvailable)
    }

    public func isAvailable(_ kind: PermissionKind) -> Bool {
        capabilities.supports(permission: kind) && providers[kind] != nil
    }

    public func status(of kind: PermissionKind) -> PermissionStatus? {
        guard isAvailable(kind) else { return .unavailable }
        return statuses[kind]
    }

    public func refresh() async {
        for kind in availableKinds {
            await refresh(kind)
        }
    }

    public func refresh(_ kind: PermissionKind) async {
        guard isAvailable(kind), let provider = providers[kind] else { return }
        statuses[kind] = await provider.currentStatus()
    }

    @discardableResult
    public func request(_ kind: PermissionKind) async -> PermissionStatus {
        guard isAvailable(kind), let provider = providers[kind] else { return .unavailable }
        let status: PermissionStatus
        if let current = statuses[kind], !current.canRequest {
            status = current
        } else if let requested = try? await provider.requestAccess() {
            status = requested
        } else {
            status = await provider.currentStatus()
        }
        statuses[kind] = status
        return status
    }
}
