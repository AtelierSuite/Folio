import Planner
import SwiftUI

struct TimelineLayerContext {
    let days: TimelineDays
    let hourHeight: CGFloat
    /// How much of today's column is on screen, from 0 to 1. Only hour label layers get a live value,
    /// so layers there can fade as today scrolls away; elsewhere it stays at 1.
    var todayOnScreen = 1.0
    /// Where the timed cards sit, so layers below them can keep their labels clear.
    var cardSlots: [TimelineSlot] = []
}

/// Extra content drawn on the timeline (reminders, weather, sleep, a second time zone)
/// without the timeline knowing about it. Day layers fill the day columns and usually
/// place their content with `TimelineSlotLayout`; gutter layers add a column before the hour labels;
/// hour label layers draw behind the hour labels.
struct TimelineLayer: Identifiable {
    enum Placement: Equatable {
        case belowEntries
        case aboveEntries
        case behindHourLabels
        case gutter(width: CGFloat)
    }

    let id: String
    let placement: Placement
    private(set) var header: AnyView?
    private let makeContent: (TimelineLayerContext) -> AnyView

    init<Content: View>(
        id: String,
        placement: Placement,
        @ViewBuilder content: @escaping (TimelineLayerContext) -> Content
    ) {
        self.id = id
        self.placement = placement
        makeContent = { AnyView(content($0)) }
    }

    func content(in context: TimelineLayerContext) -> AnyView {
        makeContent(context)
    }

    /// Shown above a gutter layer's column, next to the day headers.
    func header(@ViewBuilder _ content: () -> some View) -> TimelineLayer {
        var layer = self
        layer.header = AnyView(content())
        return layer
    }

    var gutterWidth: CGFloat {
        if case .gutter(let width) = placement { width } else { 0 }
    }
}
