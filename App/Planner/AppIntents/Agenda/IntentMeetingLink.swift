import Foundation

enum IntentMeetingLink {
    static func url(for event: CalendarEvent) -> URL? {
        MeetingLink.joinURL(in: [event.location, event.notes], url: event.url)
    }
}
