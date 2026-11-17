#if os(iOS)
import Foundation
import HealthKit

public final class HealthKitWorkoutDataSource: WorkoutDataSource {
    static let workoutType = HKObjectType.workoutType()
    let store = HKHealthStore()

    public init() {}

    public func authorizationRequestStatus() async -> WorkoutAuthorizationRequestStatus {
        guard HKHealthStore.isHealthDataAvailable() else { return .unavailable }
        let status = try? await store.statusForAuthorizationRequest(toShare: [], read: [Self.workoutType])
        return status == .shouldRequest ? .shouldRequest : .requested
    }

    public func requestAuthorization() async throws {
        try await store.requestAuthorization(toShare: [], read: [Self.workoutType])
    }

    public func workouts(in interval: DateInterval) async throws -> [Workout] {
        let predicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.workout(predicate)],
            sortDescriptors: [SortDescriptor(\.startDate)]
        )
        return try await descriptor.result(for: store).map(Workout.init(healthKitWorkout:))
    }

    public func startObservingChanges(_ onChange: @escaping @Sendable () async -> Void) {
        let query = HKObserverQuery(sampleType: Self.workoutType, predicate: nil) { _, completion, error in
            let completion = WorkoutObserverCompletion(handler: completion)
            guard error == nil else {
                completion.finish()
                return
            }
            Task {
                await onChange()
                completion.finish()
            }
        }
        store.execute(query)
    }
}

private struct WorkoutObserverCompletion: @unchecked Sendable {
    let handler: HKObserverQueryCompletionHandler

    func finish() {
        handler()
    }
}
#endif
