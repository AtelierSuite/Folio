import Planner
import SwiftUI

struct CalendarMonthDayCellView: View {
    let day: MonthDay
    let items: [MonthDayItem]
    let calendar: Calendar
    let isSelected: Bool

    private var identifierDate: String {
        day.date.formatted(Date.ISO8601FormatStyle(timeZone: calendar.timeZone).year().month().day())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .top, spacing: 2) {
                CalendarMonthDayNumberView(day: day, isToday: calendar.isDateInToday(day.date))
                Spacer(minLength: 0)
                CalendarMonthWeatherSlot(date: day.date)
            }
            CalendarMonthDayItemsView(items: items, day: day.date)
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(isSelected ? Color.accentColor.opacity(0.08) : Color.clear)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("MonthDay.\(identifierDate)")
    }
}
