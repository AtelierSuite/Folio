import CoreLocation
import EventKit

extension EventDraft {
    init(_ event: EKEvent) {
        let coordinate = event.structuredLocation?.geoLocation.map {
            EventCoordinate(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
        }
        self.init(
            title: event.title ?? "",
            calendarIdentifier: event.calendar?.calendarIdentifier ?? "",
            startDate: event.startDate,
            endDate: event.endDate,
            isAllDay: event.isAllDay,
            timeZone: event.timeZone,
            recurrence: event.recurrenceRules?.first.flatMap(EventRecurrence.init),
            alerts: (event.alarms ?? [])
                .filter { $0.absoluteDate == nil }
                .map { EventAlert(offset: $0.relativeOffset) },
            location: EventLocation(text: event.location, coordinate: coordinate),
            url: event.url,
            notes: event.notes ?? ""
        )
    }

    /// Recurrence and alerts are only rewritten when they changed, so rules and alarms this
    /// editor can't represent (such as weekdays or absolute alarms) survive other edits.
    func apply(to event: EKEvent, in eventStore: EKEventStore, original: EventDraft?) {
        event.title = title
        if event.calendar?.calendarIdentifier != calendarIdentifier,
           let calendar = eventStore.calendar(withIdentifier: calendarIdentifier) {
            event.calendar = calendar
        }
        event.isAllDay = isAllDay
        event.startDate = startDate
        event.endDate = endDate
        event.timeZone = savedTimeZone
        event.location = location?.text
        event.structuredLocation = location?.structuredLocation
        event.url = url
        event.notes = notes.isEmpty ? nil : notes
        if original == nil || recurrence != original?.recurrence {
            event.recurrenceRules = recurrence.map { [$0.recurrenceRule] }
        }
        if original == nil || alerts != original?.alerts {
            event.alarms = alerts.map { EKAlarm(relativeOffset: $0.offset) }
        }
    }
}

extension EventLocation {
    var structuredLocation: EKStructuredLocation? {
        guard let coordinate else { return nil }
        let structuredLocation = EKStructuredLocation(title: text)
        structuredLocation.geoLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return structuredLocation
    }
}
