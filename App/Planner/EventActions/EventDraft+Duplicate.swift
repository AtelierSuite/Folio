import Foundation

extension EventDraft {
    /// A copy of this occurrence as a new, single event. A copy of an event from a read-only
    /// calendar goes into `fallbackCalendarIdentifier`.
    public func duplicated(
        writableCalendarIdentifiers: Set<String>,
        fallbackCalendarIdentifier: String?
    ) -> EventDraft {
        var copy = self
        copy.recurrence = nil
        if !writableCalendarIdentifiers.contains(calendarIdentifier) {
            copy.calendarIdentifier = fallbackCalendarIdentifier ?? ""
        }
        return copy
    }

    public func moved(toCalendar calendarIdentifier: String) -> EventDraft {
        var moved = self
        moved.calendarIdentifier = calendarIdentifier
        return moved
    }
}
