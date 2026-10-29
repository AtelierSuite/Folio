import Planner
import SwiftUI

/// The shared time grid behind the day, multi-day and week views. A `zoom` controller makes it
/// pinch to zoom; without one it stays at `hourHeight`. `days` sets how many columns are shown.
struct CalendarTimelineView: View {
    let entries: [TimelineEntry]
    let days: TimelineDays
    var hourHeight: CGFloat = 48
    var zoom: TimelineZoomController?
    var layers: [TimelineLayer] = []
    var floatingSourceTimeZone: TimeZone = .current
    var initialHour: Double = 8
    var metrics = TimelineMetrics()
    var onSelectEntry: ((TimelineEntry) -> Void)?

    private var gutterLayers: [TimelineLayer] {
        layers.filter { $0.gutterWidth > 0 }
    }

    private var gutterWidth: CGFloat {
        metrics.hourLabelWidth + gutterLayers.reduce(0) { $0 + $1.gutterWidth }
    }

    var body: some View {
        let engine = TimelineLayoutEngine(days: days, floatingSourceTimeZone: floatingSourceTimeZone)
        let layout = engine.layout(entries)
        VStack(spacing: 0) {
            TimelineDayHeaderView(days: days, gutterWidth: gutterWidth, gutterLayers: gutterLayers)
            TimelineAllDayStripView(
                layout: layout,
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
                    hourHeight: hourHeight,
                    layers: layers,
                    gutterLayers: gutterLayers,
                    metrics: metrics,
                    onSelectEntry: onSelectEntry
                )
            }
        }
        .coordinateSpace(TimelineDragController.coordinateSpace)
    }
}
