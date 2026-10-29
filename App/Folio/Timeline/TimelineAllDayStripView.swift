import Planner
import SwiftUI

struct TimelineAllDayStripView: View {
    let layout: TimelineLayout
    let gutterWidth: CGFloat
    let metrics: TimelineMetrics
    var onSelectEntry: ((TimelineEntry) -> Void)?

    var body: some View {
        let laneCount = max(layout.allDayLaneCount, 1)
        HStack(alignment: .top, spacing: 0) {
            Text(String(localized: "AllDay", table: "Timeline"))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: gutterWidth - 6, height: metrics.allDayLaneHeight, alignment: .trailing)
                .padding(.trailing, 6)
            ScrollView(.vertical) {
                TimelineAllDayLayout(
                    dayCount: layout.days.count,
                    laneCount: laneCount,
                    laneHeight: metrics.allDayLaneHeight
                ) {
                    ForEach(layout.allDayPlacements) { placement in
                        Group {
                            if placement.entry.kind == .reminder {
                                TimelineAllDayReminderCardView(placement: placement, onSelect: onSelectEntry)
                            } else {
                                TimelineAllDayCardView(placement: placement)
                                    .timelineEntrySelection(placement.entry, onSelect: onSelectEntry)
                            }
                        }
                        .timelineAllDayPlacement(placement)
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .frame(height: min(CGFloat(laneCount), metrics.maximumVisibleAllDayLanes) * metrics.allDayLaneHeight)
        .padding(.vertical, 2)
    }
}
