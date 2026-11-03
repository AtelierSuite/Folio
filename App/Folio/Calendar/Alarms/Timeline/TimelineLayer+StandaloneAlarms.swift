import SwiftUI

extension TimelineLayer {
    static var standaloneAlarms: TimelineLayer {
        TimelineLayer(id: "standaloneAlarms", placement: .aboveEntries) { context in
            StandaloneAlarmTimelineLayerView(context: context)
        }
    }
}
