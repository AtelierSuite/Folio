import EventKit

extension CalendarEvent {
    init(_ event: EKEvent) {
        let isOrganizedBySomeoneElse = event.hasAttendees && !(event.organizer?.isCurrentUser ?? true)
        let isCalendarReadOnly = !(event.calendar?.allowsContentModifications ?? false)
        self.init(
            reference: CalendarItemReference(event),
            calendarIdentifier: event.calendar?.calendarIdentifier ?? "",
            title: event.title ?? "",
            location: event.location,
            notes: event.notes,
            url: event.url,
            startDate: event.startDate,
            endDate: event.endDate,
            isAllDay: event.isAllDay,
            timeZone: event.timeZone,
            color: PlannerColor(event.calendar?.cgColor),
            isRecurring: event.hasRecurrenceRules || event.isDetached,
            hasAttendees: event.hasAttendees,
            isReadOnly: isCalendarReadOnly || isOrganizedBySomeoneElse
        )
    }
}
