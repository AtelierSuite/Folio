import Foundation

public enum CalendarDataSourceError: Error, Sendable {
    case itemNotFound
    case readOnly
}
