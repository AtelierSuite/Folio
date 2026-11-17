import Foundation

public struct Workout: Sendable, Hashable, Identifiable {
    public let id: UUID
    public let activity: WorkoutActivity
    public let interval: DateInterval

    public init(id: UUID = UUID(), activity: WorkoutActivity, interval: DateInterval) {
        self.id = id
        self.activity = activity
        self.interval = interval
    }
}
