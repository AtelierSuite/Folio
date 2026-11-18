import Foundation
@testable import Planner

final class FakeWorkoutDataSource: WorkoutDataSource, @unchecked Sendable {
    private let lock = NSLock()
    private var storedWorkouts: [Workout]
    private var storedStatus: WorkoutAuthorizationRequestStatus
    private var storedFetchCount = 0
    private var storedRequestCount = 0
    private var storedOnChange: (@Sendable () async -> Void)?

    init(workouts: [Workout] = [], status: WorkoutAuthorizationRequestStatus = .shouldRequest) {
        storedWorkouts = workouts
        storedStatus = status
    }

    var workouts: [Workout] {
        get { lock.withLock { storedWorkouts } }
        set { lock.withLock { storedWorkouts = newValue } }
    }

    var fetchCount: Int { lock.withLock { storedFetchCount } }
    var requestCount: Int { lock.withLock { storedRequestCount } }
    var isObserving: Bool { lock.withLock { storedOnChange != nil } }

    func authorizationRequestStatus() async -> WorkoutAuthorizationRequestStatus {
        lock.withLock { storedStatus }
    }

    func requestAuthorization() async throws {
        lock.withLock {
            storedRequestCount += 1
            storedStatus = .requested
        }
    }

    func workouts(in interval: DateInterval) async throws -> [Workout] {
        lock.withLock {
            storedFetchCount += 1
            return storedWorkouts.filter { $0.interval.intersects(interval) }
        }
    }

    func startObservingChanges(_ onChange: @escaping @Sendable () async -> Void) {
        lock.withLock { storedOnChange = onChange }
    }

    func simulateChange() async {
        let onChange = lock.withLock { storedOnChange }
        await onChange?()
    }
}
