import Planner
import SwiftUI

struct TimelineAllDayStripView: View {
    let layout: TimelineLayout
    let pages: TimelinePages
    let frames: TimelinePageFrames
    let scrolledPage: Date?
    let gutterWidth: CGFloat
    let metrics: TimelineMetrics
    let isScrolling: Bool
    var onSelectEntry: ((TimelineEntry) -> Void)?
    @State private var settledLaneCount: Int?

    var body: some View {
        let laneCount = max(laneCountOnScreen, 1)
        let visibleLaneCount = settledLaneCount ?? laneCount
        HStack(alignment: .top, spacing: 0) {
            Text(String(localized: "AllDay", table: "Timeline"))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: gutterWidth - 6, height: metrics.allDayLaneHeight, alignment: .trailing)
                .padding(.trailing, 6)
            ScrollView(.vertical) {
                TimelinePagedRow(frames: frames, pages: pages, scrolledPage: scrolledPage) { page in
                    TimelineAllDayPageView(
                        layout: pages.dayRange(of: page).map(layout.page) ?? layout.page(0..<0),
                        laneCount: laneCount,
                        laneHeight: metrics.allDayLaneHeight,
                        onSelectEntry: onSelectEntry
                    )
                }
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .frame(height: min(CGFloat(visibleLaneCount), metrics.maximumVisibleAllDayLanes) * metrics.allDayLaneHeight)
        .padding(.vertical, 2)
        .animation(.snappy, value: visibleLaneCount)
        .onChange(of: laneCount, initial: true) { settleLaneCount(laneCount) }
        .onChange(of: isScrolling) { settleLaneCount(laneCount) }
    }

    /// The strip only resizes once a scroll comes to rest, so it doesn't jump as pages pass by.
    private func settleLaneCount(_ laneCount: Int) {
        guard !isScrolling else { return }
        settledLaneCount = laneCount
    }

    /// Lanes are counted over the days on screen, so the strip only grows for what can be seen.
    private var laneCountOnScreen: Int {
        guard let scrolledPage, let range = pages.dayRange(of: scrolledPage) else { return layout.allDayLaneCount }
        return layout.page(range.lowerBound..<(range.lowerBound + pages.columnsOnScreen)).allDayLaneCount
    }
}

struct TimelineAllDayPageView: View {
    @Environment(TimelineDragController.self) private var drag: TimelineDragController?
    let layout: TimelineLayout
    let laneCount: Int
    let laneHeight: CGFloat
    var onSelectEntry: ((TimelineEntry) -> Void)?

    var body: some View {
        TimelineAllDayLayout(dayCount: layout.days.count, laneCount: laneCount, laneHeight: laneHeight) {
            ForEach(layout.allDayPlacements) { placement in
                Group {
                    if placement.entry.kind == .reminder {
                        TimelineAllDayReminderCardView(placement: placement, onSelect: onSelectEntry)
                    } else {
                        TimelineAllDayCardView(placement: placement)
                            .timelineEntrySelection(placement.entry, onSelect: onSelectEntry)
                    }
                }
                .opacity(placement.entry.id == drag?.session?.entry.id ? 0.35 : 1)
                .timelineReminderPlacing(placement.entry, drag: drag)
                .timelineAllDayPlacement(placement)
            }
        }
    }
}
