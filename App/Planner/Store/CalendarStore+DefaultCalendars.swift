import Foundation

extension CalendarStore {
    public func isDefault(_ calendar: PlannerCalendar) -> Bool {
        switch calendar.kind {
        case .event: defaultEventCalendarIdentifier == calendar.id
        case .reminder: defaultReminderListIdentifier == calendar.id
        }
    }

    public func setDefault(_ calendar: PlannerCalendar) {
        guard !calendar.isReadOnly else { return }
        switch calendar.kind {
        case .event:
            chosenEventCalendarIdentifier = calendar.id
            visibilityStorage.defaultEventCalendarIdentifier = calendar.id
        case .reminder:
            chosenReminderListIdentifier = calendar.id
            visibilityStorage.defaultReminderListIdentifier = calendar.id
        }
    }
}
