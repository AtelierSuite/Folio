import Planner
import SwiftUI

struct CalendarMonthEntryChip: View {
    let item: MonthDayItem

    var body: some View {
        Group {
            if item.entry.kind == .reminder {
                CalendarMonthReminderChip(entry: item.entry)
            } else {
                CalendarMonthEventChip(item: item)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
