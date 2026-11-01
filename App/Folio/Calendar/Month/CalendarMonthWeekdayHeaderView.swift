import Planner
import SwiftUI

struct CalendarMonthWeekdayHeaderView: View {
    let grid: MonthGrid
    let showsWeekNumbers: Bool
    let weekNumberWidth: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            if showsWeekNumbers {
                Color.clear
                    .frame(width: weekNumberWidth, height: 1)
            }
            ForEach(grid.orderedWeekdays, id: \.self) { weekday in
                CalendarMonthWeekdayLabel(weekday: weekday, calendar: grid.calendar)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 4)
    }
}

struct CalendarMonthWeekdayLabel: View {
    @Environment(\.dayHighlighter) private var dayHighlighter
    let weekday: Int
    let calendar: Calendar

    var body: some View {
        ViewThatFits(in: .horizontal) {
            Text(calendar.shortStandaloneWeekdaySymbols[weekday - 1])
            Text(calendar.veryShortStandaloneWeekdaySymbols[weekday - 1])
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(labelStyle)
        .lineLimit(1)
        .accessibilityLabel(calendar.standaloneWeekdaySymbols[weekday - 1])
    }

    private var labelStyle: AnyShapeStyle {
        dayHighlighter.isWeekend(weekday: weekday) ? AnyShapeStyle(Color.dayHighlight) : AnyShapeStyle(.secondary)
    }
}
