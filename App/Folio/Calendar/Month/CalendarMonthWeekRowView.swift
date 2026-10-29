import Planner
import SwiftUI

struct CalendarMonthWeekRowView: View {
    @Environment(CalendarNavigation.self) private var navigation
    let week: MonthWeek
    let buckets: MonthDayBuckets
    let calendar: Calendar
    let showsWeekNumber: Bool
    let weekNumberWidth: CGFloat
    let onSelectDay: (MonthDay) -> Void

    var body: some View {
        HStack(spacing: 0) {
            if showsWeekNumber {
                CalendarMonthWeekNumberView(weekNumber: week.weekNumber, width: weekNumberWidth)
            }
            ForEach(week.days) { day in
                CalendarMonthDayCellView(
                    day: day,
                    items: buckets.items(on: day),
                    calendar: calendar,
                    isSelected: day.date == navigation.selectedDate
                )
                .onTapGesture {
                    onSelectDay(day)
                }
                .accessibilityAction {
                    onSelectDay(day)
                }
                if day.id != week.days.last?.id {
                    Divider()
                }
            }
        }
    }
}
