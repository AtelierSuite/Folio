import Foundation

/// Calendar.app on macOS opens `ical://ekevent/<identifier>?method=show&options=more` at the event.
/// Recurring occurrences need their start (in UTC) before the identifier to land on the right day.
public enum CalendarAppLink {
    public static func url(for event: CalendarEvent) -> URL? {
        var components = URLComponents()
        components.scheme = "ical"
        components.host = "ekevent"
        let identifier = event.reference.localIdentifier
        if event.isRecurring {
            components.path = "/\(occurrenceFormat.format(event.startDate))/\(identifier)"
        } else {
            components.path = "/\(identifier)"
        }
        components.queryItems = [
            URLQueryItem(name: "method", value: "show"),
            URLQueryItem(name: "options", value: "more")
        ]
        return components.url
    }

    private static let occurrenceFormat = Date.ISO8601FormatStyle(
        dateSeparator: .omitted,
        dateTimeSeparator: .standard,
        timeSeparator: .omitted,
        timeZone: .gmt
    )
}
