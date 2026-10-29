import EventKit

extension CalendarEvent {
    init(_ event: EKEvent) {
        let isOrganizedBySomeoneElse = event.hasAttendees && !(event.organizer?.isCurrentUser ?? true)
        let isCalendarReadOnly = !(event.calendar?.allowsContentModifications ?? false)
        let organizer = event.organizer.map(EventParticipant.init)
        let attendees = (event.attendees ?? []).map(EventParticipant.init)
        self.init(
            reference: CalendarItemReference(event),
            calendarIdentifier: event.calendar?.calendarIdentifier ?? "",
            title: event.title ?? "",
            location: event.location,
            coordinate: event.structuredLocation?.geoLocation.map {
                PlannerCoordinate(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            },
            notes: event.notes,
            url: event.url,
            startDate: event.startDate,
            endDate: event.endDate,
            isAllDay: event.isAllDay,
            timeZone: event.timeZone,
            color: PlannerColor(event.calendar?.cgColor),
            isRecurring: event.hasRecurrenceRules || event.isDetached,
            hasAttendees: event.hasAttendees,
            isReadOnly: isCalendarReadOnly || isOrganizedBySomeoneElse,
            alarms: CalendarAlarm.alarms(of: event),
            organizer: organizer,
            attendees: attendees,
            userStatus: .currentUserStatus(organizer: organizer, attendees: attendees)
        )
    }
}
