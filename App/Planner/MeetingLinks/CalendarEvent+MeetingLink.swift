import Foundation

extension CalendarEvent {
    public var meetingLink: MeetingLink? {
        MeetingLinkCache.shared.link(for: MeetingLinkSource(url: url, location: location, notes: notes))
    }
}
