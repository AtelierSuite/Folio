import Foundation

public enum EventEditingError: Error, Sendable {
    case readOnly
    case noWritableCalendar
    case invalidDates
}
