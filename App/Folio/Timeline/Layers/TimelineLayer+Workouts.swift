import Planner
import SwiftUI

extension TimelineLayer {
    static var workouts: TimelineLayer {
        TimelineLayer(id: "workouts", placement: .belowEntries) { context in
            WorkoutTimelineLayerView(context: context)
        }
    }
}
