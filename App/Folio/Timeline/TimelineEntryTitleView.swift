import Planner
import SwiftUI

struct TimelineEntryTitleView: View {
    let entry: TimelineEntry

    var body: some View {
        HStack(spacing: 3) {
            if entry.kind == .reminder {
                Image(systemName: "circle")
                    .imageScale(.small)
                    .accessibilityLabel(String(localized: "Accessibility.Reminder", table: "Timeline"))
            }
            Text(entry.title)
        }
    }
}
