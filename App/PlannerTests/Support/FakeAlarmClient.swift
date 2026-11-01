import Foundation
import Synchronization
@testable import Planner

final class FakeAlarmClient: AlarmSchedulingClient {
    struct State {
        var authorization: NotificationAuthorization
        var scheduled: [UUID: AlarmRequest?] = [:]
        var limit = Int.max
        var scheduleCount = 0
        var cancelCount = 0
    }

    let state: Mutex<State>

    init(authorization: NotificationAuthorization = .authorized, foreignIdentifiers: [UUID] = []) {
        var initial = State(authorization: authorization)
        for identifier in foreignIdentifiers {
            initial.scheduled[identifier] = .some(nil)
        }
        state = Mutex(initial)
    }

    var scheduledAlarms: [AlarmRequest] {
        state.withLock { $0.scheduled.values.compactMap { $0 }.sorted { $0.fireDate < $1.fireDate } }
    }

    var scheduledCount: Int {
        state.withLock { $0.scheduled.count }
    }

    var scheduleCount: Int {
        state.withLock { $0.scheduleCount }
    }

    var cancelCount: Int {
        state.withLock { $0.cancelCount }
    }

    func setLimit(_ limit: Int) {
        state.withLock { $0.limit = limit }
    }

    func setAuthorization(_ authorization: NotificationAuthorization) {
        state.withLock { $0.authorization = authorization }
    }

    func authorization() async -> NotificationAuthorization {
        state.withLock { $0.authorization }
    }

    func requestAuthorization() async throws -> NotificationAuthorization {
        state.withLock { $0.authorization }
    }

    func scheduledIdentifiers() async -> [UUID] {
        state.withLock { Array($0.scheduled.keys) }
    }

    func schedule(_ request: AlarmRequest) async throws {
        try state.withLock { state in
            guard state.scheduled.count < state.limit else { throw FakeAlarmError.limitReached }
            state.scheduled[request.id] = request
            state.scheduleCount += 1
        }
    }

    func cancel(identifiers: [UUID]) async {
        state.withLock { state in
            for identifier in identifiers where state.scheduled.removeValue(forKey: identifier) != nil {
                state.cancelCount += 1
            }
        }
    }
}

enum FakeAlarmError: Error {
    case limitReached
}
