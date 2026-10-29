import Foundation

extension CalendarStore {
    public func isVisible(_ calendar: PlannerCalendar) -> Bool {
        !hiddenCalendarIdentifiers.contains(calendar.id)
    }

    public func setVisible(_ isVisible: Bool, for calendar: PlannerCalendar) {
        if isVisible {
            hiddenCalendarIdentifiers.remove(calendar.id)
        } else {
            hiddenCalendarIdentifiers.insert(calendar.id)
        }
        visibilityStorage.hiddenCalendarIdentifiers = hiddenCalendarIdentifiers
        contentRevision += 1
    }

    public func calendar(withIdentifier identifier: String) -> PlannerCalendar? {
        eventCalendars.first { $0.id == identifier } ?? reminderLists.first { $0.id == identifier }
    }
}
