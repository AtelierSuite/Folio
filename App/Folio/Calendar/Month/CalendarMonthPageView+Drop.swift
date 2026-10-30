import Planner
import SwiftUI

extension CalendarMonthPageView {
    func drop(_ payload: CalendarItemDragPayload, on day: MonthDay, frame: CGRect) -> Bool {
        let calendar = grid.calendar
        guard calendar.startOfDay(for: payload.sourceDay) != day.date else { return false }
        if let event = eventsByEntryIdentifier[payload.entryIdentifier] {
            let interval = CalendarDayMove.interval(
                DateInterval(start: event.startDate, end: max(event.startDate, event.endDate)),
                isAllDay: event.isAllDay, from: payload.sourceDay, to: day.date, calendar: calendar
            )
            perform(.event(event), to: interval, hasDueTime: !event.isAllDay, anchor: frame)
            return true
        }
        if let reminder = remindersByEntryIdentifier[payload.entryIdentifier], let dueDate = reminder.dueDate {
            let moved = CalendarDayMove.date(dueDate, from: payload.sourceDay, to: day.date, calendar: calendar)
            perform(
                .reminder(reminder), to: DateInterval(start: moved, duration: 0), hasDueTime: reminder.hasDueTime,
                anchor: frame
            )
            return true
        }
        return false
    }

    private func perform(_ source: CalendarDragSource, to interval: DateInterval, hasDueTime: Bool, anchor: CGRect) {
        dropHandler.spanDialogAnchor = anchor
        Task {
            await dropHandler.move(
                source, to: interval, hasDueTime: hasDueTime, store: store, undoCoordinator: undoCoordinator
            )
        }
    }
}
