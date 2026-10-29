import Planner
import SwiftUI

/// The lifted card at the time it would be dropped at. It doesn't take touches, so the
/// gesture keeps tracking on the grid underneath.
struct TimelineDragPreviewView: View {
    @Environment(TimelineDragController.self) private var drag: TimelineDragController?
    let days: TimelineDays
    let hourHeight: CGFloat
    let minimumCardHeight: CGFloat

    var body: some View {
        if let session = drag?.session, let proposal = session.proposal {
            let timeZone = days.calendar.timeZone
            let engine = TimelineLayoutEngine(days: days, floatingSourceTimeZone: timeZone)
            TimelineCardsView(
                layout: engine.layout([session.previewEntry(for: proposal, in: timeZone)]),
                hourHeight: hourHeight,
                minimumCardHeight: minimumCardHeight
            )
            .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}
