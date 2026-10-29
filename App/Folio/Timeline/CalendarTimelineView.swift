import Planner
import SwiftUI

/// The shared time grid behind the day, multi-day and week views. `hourHeight` is an input so
/// pinch to zoom can drive it, and `days` sets how many columns are shown.
struct CalendarTimelineView: View {
    let entries: [TimelineEntry]
    let days: TimelineDays
    var hourHeight: CGFloat = 48
    var layers: [TimelineLayer] = []
    var floatingSourceTimeZone: TimeZone = .current
    var initialHour: Double = 8
    var metrics = TimelineMetrics()

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
            TimelineDayHeaderView(days: days, gutterWidth: gutterWidth)
            TimelineAllDayStripView(layout: layout, gutterWidth: gutterWidth, metrics: metrics)
            Divider()
            ScrollView(.vertical) {
                TimelineGridContentView(
                    layout: layout,
                    hourHeight: hourHeight,
                    layers: layers,
                    gutterLayers: gutterLayers,
                    metrics: metrics
                )
            }
            .defaultScrollAnchor(UnitPoint(x: 0, y: initialHour / 24))
        }
    }
}
