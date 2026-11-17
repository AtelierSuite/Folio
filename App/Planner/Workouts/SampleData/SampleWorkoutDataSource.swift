#if DEBUG
import Foundation

/// Made-up workouts for screenshots, read without Health access. Turned on with `-FolioSampleWorkouts`.
public struct SampleWorkoutDataSource: WorkoutDataSource {
    public static let launchArgument = "-FolioSampleWorkouts"

    private let calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    public func authorizationRequestStatus() async -> WorkoutAuthorizationRequestStatus {
        .requested
    }

    public func requestAuthorization() async throws {}

    public func workouts(in interval: DateInterval) async throws -> [Workout] {
        WorkoutSampleData.workouts(days: 14, endingBefore: Date(), calendar: calendar)
            .filter { $0.interval.intersects(interval) }
    }

    public func startObservingChanges(_ onChange: @escaping @Sendable () async -> Void) {}
}
#endif
