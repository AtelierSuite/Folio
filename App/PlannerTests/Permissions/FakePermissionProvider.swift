import Foundation
@testable import Planner

@MainActor
final class FakePermissionProvider: PermissionProvider {
    var status: PermissionStatus
    var statusAfterRequest: PermissionStatus
    var shouldThrow = false
    private(set) var requestCount = 0

    init(status: PermissionStatus, statusAfterRequest: PermissionStatus = .granted) {
        self.status = status
        self.statusAfterRequest = statusAfterRequest
    }

    func currentStatus() async -> PermissionStatus {
        status
    }

    func requestAccess() async throws -> PermissionStatus {
        requestCount += 1
        if shouldThrow {
            throw CancellationError()
        }
        status = statusAfterRequest
        return status
    }
}
