import Planner
import SwiftUI

/// The hour grid, layers and cards of one page.
struct TimelinePageGridView: View {
    @Environment(TimelineDragController.self) private var drag: TimelineDragController?
    let layout: TimelineLayout
    let hourHeight: CGFloat
    let layers: [TimelineLayer]
    let metrics: TimelineMetrics
    var onSelectEntry: ((TimelineEntry) -> Void)?

    var body: some View {
        let context = TimelineLayerContext(days: layout.days, hourHeight: hourHeight)
        let minimumCardHeight = metrics.minimumCardHeight(hourHeight: hourHeight)
        ZStack(alignment: .topLeading) {
            TimelineHourGridView(dayCount: layout.days.count, hourHeight: hourHeight)
                .timelineCreationTap(days: layout.days, hourHeight: hourHeight)
            TimelineLayersView(layers: layers.filter { $0.placement == .belowEntries }, context: context)
            TimelineCardsView(
                layout: layout,
                hourHeight: hourHeight,
                minimumCardHeight: minimumCardHeight,
                draggedEntryIdentifier: drag?.session?.entry.id,
                onSelectEntry: onSelectEntry
            )
            .environment(\.eventCardsLiftToDrag, drag != nil)
            TimelineLayersView(layers: layers.filter { $0.placement == .aboveEntries }, context: context)
            TimelineCurrentTimeIndicatorView(days: layout.days, hourHeight: hourHeight)
            TimelineDragPreviewView(days: layout.days, hourHeight: hourHeight, minimumCardHeight: minimumCardHeight)
        }
        .frame(height: hourHeight * 24)
    }
}
