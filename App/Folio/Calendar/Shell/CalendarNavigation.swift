import Foundation
import Observation

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
        let step = forward ? 1 : -1
        if let date = calendar.date(byAdding: mode.pagingComponent, value: step, to: selectedDate) {
            selectedDate = calendar.startOfDay(for: date)
        }
    }

    func startOfWeek(containing date: Date) -> Date {
        calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? calendar.startOfDay(for: date)
    }
}
