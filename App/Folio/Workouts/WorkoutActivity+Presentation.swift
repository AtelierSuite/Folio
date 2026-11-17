import Planner
import SwiftUI

extension WorkoutActivity {
    var title: String {
        let key = "Activity." + rawValue.prefix(1).uppercased() + rawValue.dropFirst()
        return String(localized: String.LocalizationValue(key), table: "Workouts")
    }

    var systemImage: String {
        switch self {
        case .running: "figure.run"
        case .walking: "figure.walk"
        case .hiking: "figure.hiking"
        case .cycling: "figure.outdoor.cycle"
        case .swimming: "figure.pool.swim"
        case .strengthTraining: "figure.strengthtraining.traditional"
        case .functionalTraining: "figure.strengthtraining.functional"
        case .highIntensityIntervalTraining: "figure.highintensity.intervaltraining"
        case .coreTraining: "figure.core.training"
        case .yoga: "figure.yoga"
        case .pilates: "figure.pilates"
        case .dance: "figure.dance"
        case .elliptical: "figure.elliptical"
        case .rowing: "figure.rower"
        case .stairs: "figure.stair.stepper"
        case .cooldown: "figure.cooldown"
        case .other: "figure.mixed.cardio"
        }
    }
}
