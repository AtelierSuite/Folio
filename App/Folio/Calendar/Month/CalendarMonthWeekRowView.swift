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
    let onDrop: (CalendarItemDragPayload, MonthDay, CGRect) -> Bool
    @State private var targetedDay: Date?

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
                .overlay {
                    if targetedDay == day.date {
                        Rectangle().stroke(Color.accentColor, lineWidth: 2)
                    }
                }
                .calendarMonthDropDestination(isTargeted: Binding(
                    get: { targetedDay == day.date },
                    set: { isTargeted in
                        if isTargeted {
                            targetedDay = day.date
                        } else if targetedDay == day.date {
                            targetedDay = nil
                        }
                    }
                )) { payload, frame in
                    onDrop(payload, day, frame)
                }
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
