import Foundation

public enum PermissionGateState: Sendable, Equatable {
    case loading
    case unavailable
    case content(missing: [PermissionKind])
    case blocked(primary: PermissionKind, requestable: [PermissionKind])

    public init(kinds: [PermissionKind], status: (PermissionKind) -> PermissionStatus?) {
        let statuses = kinds.map { ($0, status($0)) }.filter { $0.1 != .unavailable }
        guard let primary = statuses.first?.0 else {
            self = .unavailable
            return
        }
        guard statuses.allSatisfy({ $0.1 != nil }) else {
            self = .loading
            return
        }
        if statuses.contains(where: { $0.1?.allowsAccess == true }) {
            self = .content(missing: statuses.filter { $0.1?.allowsAccess != true }.map(\.0))
        } else {
            let requestable = statuses.dropFirst().filter { $0.1?.canRequest == true }.map(\.0)
            self = .blocked(primary: primary, requestable: requestable)
        }
    }
}

extension PermissionCenter {
    public func gateState(for kinds: [PermissionKind]) -> PermissionGateState {
        PermissionGateState(kinds: kinds) { status(of: $0) }
    }
}
