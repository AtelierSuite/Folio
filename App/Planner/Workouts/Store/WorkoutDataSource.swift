import Foundation

public enum WorkoutAuthorizationRequestStatus: Sendable, Equatable {
    case shouldRequest
    case requested
    case unavailable
}

/// Reads workouts from the system. Workouts are only ever held in memory.
public protocol WorkoutDataSource: Sendable {
    func authorizationRequestStatus() async -> WorkoutAuthorizationRequestStatus
    func requestAuthorization() async throws
    func workouts(in interval: DateInterval) async throws -> [Workout]
    /// Calls `onChange` whenever a workout is saved, and awaits it before telling the system the update was handled.
    func startObservingChanges(_ onChange: @escaping @Sendable () async -> Void)
}
