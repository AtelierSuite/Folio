import Planner
import SwiftUI

struct CalendarMonthReminderChip: View {
    let entry: TimelineEntry
    @AppStorage(TimelineSettings.compressesTextKey) private var compressesText = false

    var body: some View {
        HStack(spacing: 1) {
            TimelineReminderCheckbox(entry: entry)
            TimelineReminderTitleView(entry: entry)
                .horizontalTextFit(isEnabled: compressesText)
        }
        .font(.caption2)
        .lineLimit(1)
        .padding(.trailing, 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
