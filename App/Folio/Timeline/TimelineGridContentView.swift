import Planner
import SwiftUI

struct TimelineGridContentView: View {
    let layout: TimelineLayout
    let hourHeight: CGFloat
    let layers: [TimelineLayer]
    let gutterLayers: [TimelineLayer]
    let metrics: TimelineMetrics
    var onSelectEntry: ((TimelineEntry) -> Void)?

    var body: some View {
        let context = TimelineLayerContext(days: layout.days, hourHeight: hourHeight)
        HStack(alignment: .top, spacing: 0) {
            TimelineLayersView(layers: gutterLayers, context: context)
            TimelineHourLabelsView(hourHeight: hourHeight, width: metrics.hourLabelWidth)
            ZStack(alignment: .topLeading) {
                TimelineHourGridView(dayCount: layout.days.count, hourHeight: hourHeight)
                TimelineLayersView(layers: layers.filter { $0.placement == .belowEntries }, context: context)
                TimelineCardsView(
                    layout: layout,
                    hourHeight: hourHeight,
                    minimumCardHeight: metrics.minimumCardHeight(hourHeight: hourHeight),
                    onSelectEntry: onSelectEntry
                )
                TimelineLayersView(layers: layers.filter { $0.placement == .aboveEntries }, context: context)
                TimelineCurrentTimeIndicatorView(days: layout.days, hourHeight: hourHeight)
            }
        }
        .frame(height: hourHeight * 24)
        .padding(.vertical, metrics.verticalInset)
    }
}

extension TimelineSlot {
    init(_ segment: TimelineDaySegment) {
        self.init(dayIndex: segment.dayIndex, startHour: segment.startHour, endHour: segment.endHour)
    }

    init(_ position: TimelineTimePosition) {
        self.init(dayIndex: position.dayIndex, startHour: position.hour, endHour: position.hour)
    }

    init(_ placement: TimelineTimedPlacement) {
        self.init(
            dayIndex: placement.dayIndex,
            startHour: placement.startHour,
            endHour: placement.endHour,
            leadingFraction: placement.leadingFraction,
            widthFraction: placement.widthFraction
        )
    }
}
