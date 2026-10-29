import EventKit

extension CalendarItemReference {
    init(_ event: EKEvent) {
        let isRecurring = event.hasRecurrenceRules || event.isDetached
        self.init(
            externalIdentifier: event.calendarItemExternalIdentifier,
            localIdentifier: event.calendarItemIdentifier,
            calendarIdentifier: event.calendar?.calendarIdentifier ?? "",
            occurrenceDate: isRecurring ? event.occurrenceDate : nil,
            title: event.title ?? "",
            startDate: event.startDate
        )
    }

    init(_ reminder: EKReminder) {
        self.init(
            externalIdentifier: reminder.calendarItemExternalIdentifier,
            localIdentifier: reminder.calendarItemIdentifier,
            calendarIdentifier: reminder.calendar?.calendarIdentifier ?? "",
            title: reminder.title ?? "",
            startDate: reminder.dueDateComponents?.resolvedDate
        )
    }
}
