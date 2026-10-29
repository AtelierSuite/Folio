import Foundation

/// The one place notifications find an event's meeting link, so it can follow the meeting link detector (#16).
public enum NotificationMeetingLink {
    public static func url(for event: CalendarEvent) -> URL? {
        MeetingLink.joinURL(in: [event.location, event.notes], url: event.url)
    }

    static func isWebLink(_ text: String) -> Bool {
        guard let url = URL(string: text), let scheme = url.scheme?.lowercased() else { return false }
        return (scheme == "http" || scheme == "https") && url.host() != nil
    }
}
