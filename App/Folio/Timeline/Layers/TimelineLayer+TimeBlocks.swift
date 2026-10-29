import Planner
import SwiftUI

extension TimelineLayer {
    static func timeBlocks(id: String, intervals: [DateInterval], style: some ShapeStyle) -> TimelineLayer {
        TimelineLayer(id: id, placement: .belowEntries) { context in
            TimelineTimeBlocksView(intervals: intervals, style: AnyShapeStyle(style), context: context)
        }
    }
}

struct TimelineTimeBlocksView: View {
    let intervals: [DateInterval]
    let style: AnyShapeStyle
    let context: TimelineLayerContext

    var body: some View {
        let segments = intervals.flatMap { context.days.segments(from: $0.start, to: $0.end) }
        TimelineSlotLayout(dayCount: context.days.count, hourHeight: context.hourHeight) {
            ForEach(segments, id: \.self) { segment in
                Rectangle()
                    .fill(style)
                    .timelineSlot(TimelineSlot(segment))
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
