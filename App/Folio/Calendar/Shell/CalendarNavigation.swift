import Foundation
import Observation
import Planner

@MainActor
@Observable
final class CalendarNavigation {
    var selectedDate: Date
    var calendar: Calendar

    init(selectedDate: Date = .now, calendar: Calendar = .current) {
        self.calendar = calendar
        self.selectedDate = calendar.startOfDay(for: selectedDate)
    }

    var isShowingToday: Bool {
        calendar.isDateInToday(selectedDate)
    }

    func goToToday() {
        selectedDate = calendar.startOfDay(for: .now)
    }

    func show(_ date: Date) {
        selectedDate = calendar.startOfDay(for: date)
    }

    func page(_ mode: CalendarViewMode, forward: Bool) {
        page(by: mode.pageStep, toward: forward ? .forward : .backward)
    }

    func page(by step: CalendarPageStep, toward direction: CalendarPageDirection) {
        selectedDate = step.date(from: selectedDate, toward: direction, in: calendar)
    }

    func adopt(_ newCalendar: Calendar) {
        guard newCalendar != calendar else { return }
        selectedDate = newCalendar.startOfSameDay(as: selectedDate, in: calendar)
        calendar = newCalendar
    }

    func startOfWeek(containing date: Date) -> Date {
        calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? calendar.startOfDay(for: date)
    }
}
