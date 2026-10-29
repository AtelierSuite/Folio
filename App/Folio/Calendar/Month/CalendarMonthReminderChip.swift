import Planner
import SwiftUI

struct CalendarMonthReminderChip: View {
    let entry: TimelineEntry

    var body: some View {
        HStack(spacing: 1) {
            TimelineReminderCheckbox(entry: entry)
            TimelineReminderTitleView(entry: entry)
        }
        .font(.caption2)
        .lineLimit(1)
        .padding(.trailing, 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
