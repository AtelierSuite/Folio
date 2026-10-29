import Planner
import SwiftUI

struct CalendarMonthEntryChip: View {
    let item: MonthDayItem

    var body: some View {
        Group {
            if item.isSpanning && item.entry.kind == .event {
                CalendarMonthSpanningChip(item: item)
            } else {
                CalendarMonthTimedChip(entry: item.entry)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
