import Planner
import SwiftUI

/// The hour labels and gutter layers, which stay put, next to the horizontally scrolling pages.
struct TimelineGridContentView: View {
    @Environment(TimelineDragController.self) private var drag: TimelineDragController?
    let layout: TimelineLayout
    let pages: TimelinePages
    @Binding var position: ScrollPosition
    let frames: TimelinePageFrames
    let hourHeight: CGFloat
    let layers: [TimelineLayer]
    let gutterLayers: [TimelineLayer]
    let metrics: TimelineMetrics
    let isPinching: Bool
    var onSelectEntry: ((TimelineEntry) -> Void)?
    var onScrollPhaseChange: ((ScrollPhase) -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            TimelineLayersView(
                layers: gutterLayers,
                context: TimelineLayerContext(days: gutterDays, hourHeight: hourHeight)
            )
            TimelineHourLabelsView(hourHeight: hourHeight, width: metrics.hourLabelWidth)
            TimelinePageScrollView(
                pages: pages,
                position: $position,
                frames: frames,
                isScrollDisabled: isPinching,
                onScrollPhaseChange: onScrollPhaseChange
            ) { page in
                TimelinePageGridView(
                    layout: pages.dayRange(of: page).map(layout.page) ?? layout.page(0..<0),
                    hourHeight: hourHeight,
                    layers: layers,
                    metrics: metrics,
                    onSelectEntry: onSelectEntry
                )
            }
        }
        .frame(height: hourHeight * 24)
        .padding(.vertical, metrics.verticalInset)
        .onChange(of: DragLayoutKey(layout: layout, hourHeight: hourHeight), initial: true) { _, key in
            drag?.update(
                layout: key.layout,
                hourHeight: key.hourHeight,
                minimumCardHeight: metrics.minimumCardHeight(hourHeight: key.hourHeight)
            )
        }
    }

    /// Gutter layers, such as a second time zone, label the hours of the page in view.
    private var gutterDays: TimelineDays {
        let page = position.viewID(type: Date.self) ?? pages.starts.first
        let range = page.flatMap(pages.dayRange(of:)) ?? 0..<min(pages.daysPerPage, layout.days.count)
        return layout.page(range).days
    }
}

private struct DragLayoutKey: Equatable {
    let layout: TimelineLayout
    let hourHeight: CGFloat
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
