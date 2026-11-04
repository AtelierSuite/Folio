import Planner
import SwiftUI

struct CalendarWeekDayRow: View {
    @Environment(CalendarNavigation.self) private var navigation
    let workdays: Set<Int>?

    private let minimumSwipeDistance: CGFloat = 40

    var body: some View {
        let calendar = navigation.calendar
        let dates = calendar.shownDates(inWeekContaining: navigation.selectedDate, workdays: workdays)
        HStack(spacing: 0) {
            ForEach(dates, id: \.self) { date in
                CalendarWeekDayRowButton(
                    date: date, calendar: calendar, isSelected: date == navigation.selectedDate
                ) {
                    navigation.show(date)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .simultaneousGesture(weekSwipe)
    }

    private var weekSwipe: some Gesture {
        DragGesture(minimumDistance: minimumSwipeDistance).onEnded { swipe in
            guard abs(swipe.translation.width) > abs(swipe.translation.height) else { return }
            navigation.page(by: .week, toward: swipe.translation.width < 0 ? .forward : .backward)
        }
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
