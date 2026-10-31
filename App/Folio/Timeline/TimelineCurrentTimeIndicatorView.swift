import Planner
import SwiftUI

struct TimelineCurrentTimeIndicatorView: View {
    @Environment(SystemTimeObserver.self) private var systemTime: SystemTimeObserver?
    let days: TimelineDays
    let hourHeight: CGFloat

    var body: some View {
        TimelineView(.everyMinute) { context in
            if let position = days.position(of: context.date) {
                TimelineSlotLayout(dayCount: days.count, hourHeight: hourHeight) {
                    ForEach(0..<position.dayIndex, id: \.self) { dayIndex in
                        leadingLine
                            .timelineSlot(TimelineSlot(TimelineTimePosition(dayIndex: dayIndex, hour: position.hour)))
                    }
                    indicator
                        .timelineSlot(TimelineSlot(position))
                }
            }
        }
        .id(systemTime?.changeCount)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    /// Joins the current time label in the gutter to today's column when earlier days are on the page.
    private var leadingLine: some View {
        Rectangle()
            .fill(.red.opacity(0.5))
            .frame(height: 2)
            .frame(height: 0)
    }

    private var indicator: some View {
        Rectangle()
            .fill(.red)
            .frame(height: 2)
            .frame(height: 0)
    }
}
