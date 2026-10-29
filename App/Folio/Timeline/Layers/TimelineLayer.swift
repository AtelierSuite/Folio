import Planner
import SwiftUI

struct TimelineLayerContext {
    let days: TimelineDays
    let hourHeight: CGFloat
}

/// Extra content drawn on the timeline (reminders, weather, sleep, a second time zone)
/// without the timeline knowing about it. Day layers fill the day columns and usually
/// place their content with `TimelineSlotLayout`; gutter layers add a column before the hour labels.
struct TimelineLayer: Identifiable {
    enum Placement: Equatable {
        case belowEntries
        case aboveEntries
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
