import Planner
import SwiftUI

struct TimelineCurrentTimeIndicatorView: View {
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
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var indicator: some View {
        Rectangle()
            .fill(.red)
            .frame(height: 2)
            .overlay(alignment: .leading) {
                Circle()
                    .fill(.red)
                    .frame(width: 9, height: 9)
                    .offset(x: -4.5)
            }
            .frame(height: 0)
    }
}
