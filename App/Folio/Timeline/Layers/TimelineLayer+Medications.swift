import Planner
import SwiftUI

extension TimelineLayer {
    static var medications: TimelineLayer {
        TimelineLayer(id: "medications", placement: .aboveEntries) { context in
            MedicationTimelineLayerView(context: context)
        }
    }
}
