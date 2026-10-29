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

    public func setHidesDeclinedEvents(_ hidesDeclinedEvents: Bool) {
        self.hidesDeclinedEvents = hidesDeclinedEvents
        visibilityStorage.hidesDeclinedEvents = hidesDeclinedEvents
        contentRevision += 1
    }

    func isShown(_ event: CalendarEvent) -> Bool {
        !hiddenCalendarIdentifiers.contains(event.calendarIdentifier) && !(hidesDeclinedEvents && event.isDeclined)
    }

    public func calendar(withIdentifier identifier: String) -> PlannerCalendar? {
        eventCalendars.first { $0.id == identifier } ?? reminderLists.first { $0.id == identifier }
    }
}
