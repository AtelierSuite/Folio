import Planner
import SwiftUI

struct CalendarMonthEventChip: View {
    let item: MonthDayItem
    @AppStorage(TimelineSettings.compressesTextKey) private var compressesText = false

    private let shape = Rectangle()

    var body: some View {
        TimelineEntryTitleView(entry: item.entry)
            .horizontalTextFit(isEnabled: compressesText)
            .font(.caption2.weight(.semibold))
            .lineLimit(1)
            .padding(.horizontal, 3)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .timelineCardFill(for: item.entry, in: shape)
    }
}
