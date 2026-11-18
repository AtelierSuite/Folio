#if os(iOS)
import Foundation
import HealthKit

extension Workout {
    init(healthKitWorkout workout: HKWorkout) {
        self.init(
            id: workout.uuid,
            activity: WorkoutActivity(healthKitType: workout.workoutActivityType),
            interval: DateInterval(start: workout.startDate, end: max(workout.startDate, workout.endDate))
        )
    }
}

extension WorkoutActivity {
    private static let healthKitTypes: [HKWorkoutActivityType: WorkoutActivity] = [
        .running: .running,
        .walking: .walking,
        .hiking: .hiking,
        .cycling: .cycling, .handCycling: .cycling,
        .swimming: .swimming, .waterFitness: .swimming,
        .traditionalStrengthTraining: .strengthTraining,
        .functionalStrengthTraining: .functionalTraining, .crossTraining: .functionalTraining,
        .highIntensityIntervalTraining: .highIntensityIntervalTraining,
        .coreTraining: .coreTraining,
        .yoga: .yoga, .mindAndBody: .yoga,
        .pilates: .pilates,
        .cardioDance: .dance, .socialDance: .dance, .barre: .dance,
        .elliptical: .elliptical,
        .rowing: .rowing, .paddleSports: .rowing,
        .stairs: .stairs, .stairClimbing: .stairs, .stepTraining: .stairs,
        .cooldown: .cooldown, .flexibility: .cooldown, .preparationAndRecovery: .cooldown
    ]

    init(healthKitType type: HKWorkoutActivityType) {
        self = Self.healthKitTypes[type] ?? .other
    }
}
#endif
