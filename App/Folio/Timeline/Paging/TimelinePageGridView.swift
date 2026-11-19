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
        let minimumCardHeight = metrics.minimumCardHeight(hourHeight: hourHeight)
        let context = TimelineLayerContext(
            days: layout.days, hourHeight: hourHeight, cardSlots: cardSlots(minimumCardHeight: minimumCardHeight)
        )
        ZStack(alignment: .topLeading) {
            TimelineHourGridView(dayCount: layout.days.count, hourHeight: hourHeight)
                .timelineCreationTap(days: layout.days, hourHeight: hourHeight)
            TimelineLayersView(layers: layers.filter { $0.placement == .belowEntries }, context: context)
            TimelineTravelTimeView(
                layout: layout, hourHeight: hourHeight, draggedEntryIdentifier: drag?.session?.entry.id
            )
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

    private func cardSlots(minimumCardHeight: CGFloat) -> [TimelineSlot] {
        let minimumHours = hourHeight > 0 ? Double(minimumCardHeight / hourHeight) : 0
        return layout.timedPlacements.map { placement in
            var slot = TimelineSlot(placement)
            slot.endHour = max(slot.endHour, slot.startHour + minimumHours)
            return slot
        }
    }
}
