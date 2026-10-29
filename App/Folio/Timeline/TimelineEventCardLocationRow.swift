import Planner
import SwiftUI

struct TimelineEventCardLocationRow: View {
    let entry: TimelineEntry

    var body: some View {
        HStack(spacing: 2) {
            if entry.hasLink {
                Image(systemName: "link")
                    .imageScale(.small)
                    .accessibilityLabel(String(localized: "Card.Link", table: "TimelineZoom"))
            }
            if let location = entry.location {
                Text(location)
            }
        }
    }
}
