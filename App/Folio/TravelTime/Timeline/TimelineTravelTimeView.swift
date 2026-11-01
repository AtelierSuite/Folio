import Planner
import SwiftUI

/// A band just above each upcoming event card, as tall as the trip there from the current location.
struct TimelineTravelTimeView: View {
    @Environment(\.travelEstimates) private var estimates
    let layout: TimelineLayout
    let hourHeight: CGFloat
    var draggedEntryIdentifier: String?

    var body: some View {
        if !estimates.isEmpty {
            TimelineSlotLayout(dayCount: layout.days.count, hourHeight: hourHeight) {
                ForEach(layout.timedPlacements) { placement in
                    if placement.entry.id != draggedEntryIdentifier, !placement.continuesFromPreviousDay,
                       let estimate = estimates[placement.entry.id] {
                        TimelineTravelTimeBand(estimate: estimate)
                            .timelineSlot(slot(for: placement, travelTime: estimate.travelTime))
                    }
                }
            }
            .allowsHitTesting(false)
        }
    }

    private func slot(for placement: TimelineTimedPlacement, travelTime: TimeInterval) -> TimelineSlot {
        TimelineSlot(
            dayIndex: placement.dayIndex,
            startHour: max(0, placement.startHour - travelTime / 3600),
            endHour: placement.startHour,
            leadingFraction: placement.leadingFraction,
            widthFraction: placement.widthFraction
        )
    }
}
