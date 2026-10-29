import Planner
import SwiftUI

/// Weather (#27) and sleep blocks (#28) add their timeline layers here, gated on `capabilities`.
struct CalendarTimelineOverlays {
    let capabilities: PlatformCapabilities

    func layers(for days: TimelineDays) -> [TimelineLayer] {
        []
    }
}
