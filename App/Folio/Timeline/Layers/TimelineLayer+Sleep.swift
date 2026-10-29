import Planner
import SwiftUI

extension TimelineLayer {
    static var sleep: TimelineLayer {
        TimelineLayer(id: "sleep", placement: .belowEntries) { context in
            SleepTimelineLayerView(context: context)
        }
    }
}
