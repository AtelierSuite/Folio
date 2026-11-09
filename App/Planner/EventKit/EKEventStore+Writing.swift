import EventKit

/// EventKit is read-only on watchOS, so every write goes through here and fails there.
extension EKEventStore {
    func persist(_ event: EKEvent, span: EKSpan) throws {
        #if os(watchOS)
        throw CalendarDataSourceError.readOnly
        #else
        try save(event, span: span, commit: true)
        #endif
    }

    func discard(_ event: EKEvent, span: EKSpan) throws {
        #if os(watchOS)
        throw CalendarDataSourceError.readOnly
        #else
        try remove(event, span: span, commit: true)
        #endif
    }

    func persist(_ reminder: EKReminder) throws {
        #if os(watchOS)
        throw CalendarDataSourceError.readOnly
        #else
        try save(reminder, commit: true)
        #endif
    }

    func discard(_ reminder: EKReminder) throws {
        #if os(watchOS)
        throw CalendarDataSourceError.readOnly
        #else
        try remove(reminder, commit: true)
        #endif
    }

    func persist(_ calendar: EKCalendar) throws {
        #if os(watchOS)
        throw CalendarDataSourceError.readOnly
        #else
        try saveCalendar(calendar, commit: true)
        #endif
    }
}
