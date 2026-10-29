import Foundation
import Synchronization
@testable import Planner

final class FakeNotificationCenter: NotificationCenterClient {
    struct State {
        var authorization: NotificationAuthorization
        var authorizationAfterRequest: NotificationAuthorization = .authorized
        var authorizationRequestCount = 0
        var pending: [String: PlannedNotification?] = [:]
        var addCount = 0
        var removeCount = 0
        var maximumPendingCount = 0
    }

    static let limit = 64

    let state: Mutex<State>

    init(authorization: NotificationAuthorization = .authorized, foreignIdentifiers: [String] = []) {
        var initial = State(authorization: authorization)
        for identifier in foreignIdentifiers {
            initial.pending[identifier] = .some(nil)
        }
        initial.maximumPendingCount = initial.pending.count
        state = Mutex(initial)
    }

    var pendingNotifications: [PlannedNotification] {
        state.withLock { $0.pending.values.compactMap { $0 }.sorted { $0.fireDate < $1.fireDate } }
    }

    var pendingCount: Int {
        state.withLock { $0.pending.count }
    }

    var addCount: Int {
        state.withLock { $0.addCount }
    }

    var removeCount: Int {
        state.withLock { $0.removeCount }
    }

    var maximumPendingCount: Int {
        state.withLock { $0.maximumPendingCount }
    }

    var authorizationRequestCount: Int {
        state.withLock { $0.authorizationRequestCount }
    }

    func setAuthorization(_ authorization: NotificationAuthorization, afterRequest: NotificationAuthorization) {
        state.withLock {
            $0.authorization = authorization
            $0.authorizationAfterRequest = afterRequest
        }
    }

    func authorization() async -> NotificationAuthorization {
        state.withLock { $0.authorization }
    }

    func requestAuthorization() async throws -> Bool {
        state.withLock { state in
            state.authorizationRequestCount += 1
            state.authorization = state.authorizationAfterRequest
            return state.authorization == .authorized
        }
    }

    func pendingIdentifiers() async -> [String] {
        state.withLock { Array($0.pending.keys) }
    }

    func add(_ notification: PlannedNotification, now: Date) async throws {
        try state.withLock { state in
            if state.pending[notification.id] == nil, state.pending.count >= Self.limit {
                throw FakeNotificationCenterError.limitExceeded
            }
            state.pending[notification.id] = notification
            state.addCount += 1
            state.maximumPendingCount = max(state.maximumPendingCount, state.pending.count)
        }
    }

    func removePending(withIdentifiers identifiers: [String]) async {
        state.withLock { state in
            for identifier in identifiers where state.pending.removeValue(forKey: identifier) != nil {
                state.removeCount += 1
            }
        }
    }
}

enum FakeNotificationCenterError: Error {
    case limitExceeded
}
