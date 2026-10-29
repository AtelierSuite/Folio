import Foundation

/// What an alert's actions need beyond the item itself: where Join Meeting and Directions go.
public struct NotificationActionContext: Sendable, Hashable {
    public let meetingURL: URL?
    public let place: NotificationPlace?

    public init(meetingURL: URL? = nil, place: NotificationPlace? = nil) {
        self.meetingURL = meetingURL
        self.place = place
    }

    public static let none = NotificationActionContext()

    public init(event: CalendarEvent) {
        self.init(
            meetingURL: NotificationMeetingLink.url(for: event),
            place: NotificationPlace(name: event.location, coordinate: event.coordinate)
        )
    }

    var fingerprint: [String] {
        var parts: [String] = []
        if let meetingURL {
            parts.append(meetingURL.absoluteString)
        }
        if let place {
            parts.append(place.name ?? "")
            if let coordinate = place.coordinate {
                parts.append("\(coordinate.latitude),\(coordinate.longitude)")
            }
        }
        return parts
    }
}
