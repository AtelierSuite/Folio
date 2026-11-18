import Planner
import SwiftUI

struct TimelineEntryTitleView: View {
    let entry: TimelineEntry

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            if entry.kind == .reminder {
                Image(systemName: "circle")
                    .imageScale(.small)
                    .accessibilityLabel(String(localized: "Accessibility.Reminder", table: "Timeline"))
            }
            if entry.isBirthday {
                BirthdayGlyph()
                    .imageScale(.small)
            }
            Text(entry.title)
            DuplicateCountBadge(count: entry.duplicateCount)
        }
    }
}
