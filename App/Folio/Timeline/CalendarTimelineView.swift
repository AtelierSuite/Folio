import Planner
import SwiftUI

/// The shared time grid behind the day, multi-day and week views. `layout` covers every column
/// of every page; `pages` groups them into pages that scroll horizontally under one vertical
/// scroll view, so every page shows the same hours. A `zoom` controller makes it pinch to zoom;
/// without one it stays at `hourHeight`.
struct CalendarTimelineView: View {
    let layout: TimelineLayout
    let pages: TimelinePages
    @Binding var position: ScrollPosition
    var hourHeight: CGFloat = 48
    var zoom: TimelineZoomController?
    var layers: [TimelineLayer] = []
    var initialHour: Double = 8
    var metrics = TimelineMetrics()
    var onSelectEntry: ((TimelineEntry) -> Void)?
    var onScrollPhaseChange: ((ScrollPhase) -> Void)?
    @State private var frames = TimelinePageFrames()

    private var gutterLayers: [TimelineLayer] {
        layers.filter { $0.gutterWidth > 0 }
    }

    private var gutterWidth: CGFloat {
        metrics.hourLabelWidth + gutterLayers.reduce(0) { $0 + $1.gutterWidth }
    }

    var body: some View {
        let scrolledPage = position.viewID(type: Date.self)
        VStack(spacing: 0) {
            TimelineDayHeaderView(
                days: layout.days,
                pages: pages,
                frames: frames,
                scrolledPage: scrolledPage,
                gutterWidth: gutterWidth,
                gutterLayers: gutterLayers
            )
            TimelineAllDayStripView(
                layout: layout,
                pages: pages,
                frames: frames,
                scrolledPage: scrolledPage,
                gutterWidth: gutterWidth,
                metrics: metrics,
                onSelectEntry: onSelectEntry
            )
            Divider()
            TimelineZoomScrollView(
                zoom: zoom,
                fixedHourHeight: hourHeight,
                initialHour: initialHour,
                verticalInset: metrics.verticalInset
            ) { hourHeight in
                TimelineGridContentView(
                    layout: layout,
                    pages: pages,
                    position: $position,
                    frames: frames,
                    hourHeight: hourHeight,
                    layers: layers,
                    gutterLayers: gutterLayers,
                    metrics: metrics,
                    isPinching: zoom?.isPinching ?? false,
                    onSelectEntry: onSelectEntry,
                    onScrollPhaseChange: onScrollPhaseChange
                )
            }
        }
        .coordinateSpace(TimelineDragController.coordinateSpace)
    }
}
