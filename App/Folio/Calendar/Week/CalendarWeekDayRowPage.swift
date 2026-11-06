import SwiftUI

struct CalendarWeekDayRowPage: View {
    let dates: [Date]
    let selectedDate: Date
    let calendar: Calendar
    let onSelect: (Date) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(dates, id: \.self) { date in
                CalendarWeekDayRowButton(date: date, calendar: calendar, isSelected: date == selectedDate) {
                    onSelect(date)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }
}

private struct CalendarWeekDayRowButton: View {
    let date: Date
    let calendar: Calendar
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            TimelineDayHeaderLabel(
                day: calendar.dateInterval(of: .day, for: date) ?? DateInterval(start: date, duration: 0),
                calendar: calendar,
                isSelected: isSelected
            )
            .frame(maxWidth: .infinity)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("WeekDayRow.Day.\(calendar.component(.weekday, from: date))")
    }
}
