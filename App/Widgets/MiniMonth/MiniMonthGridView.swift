import Planner
import SwiftUI
import WidgetKit

struct MiniMonthGridView: View {
    let grid: MonthGrid
    let today: Date
    let eventDays: Set<Date>

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(grid.month.start, format: .dateTime.month(.wide))
                .font(.caption.weight(.bold))
                .foregroundStyle(.tint)
                .widgetAccentable()
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                GridRow {
                    ForEach(grid.orderedWeekdays, id: \.self) { weekday in
                        Text(grid.calendar.veryShortStandaloneWeekdaySymbols[weekday - 1])
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                ForEach(grid.weeks, id: \.days.first?.date) { week in
                    GridRow {
                        ForEach(week.days) { day in
                            MiniMonthDayCell(
                                day: day,
                                isToday: grid.calendar.isDate(day.date, inSameDayAs: today),
                                hasEvents: eventDays.contains(day.date)
                            )
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
