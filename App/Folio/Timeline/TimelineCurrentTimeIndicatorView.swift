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
                    indicator
                        .timelineSlot(TimelineSlot(position))
                }
            }
        }
        .id(systemTime?.changeCount)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var indicator: some View {
        Rectangle()
            .fill(.red)
            .frame(height: 2)
            .frame(height: 0)
    }
}
