import Foundation

/// The meeting an event notification opens when tapped, while the meeting is close enough to join.
public struct NotificationMeeting: Sendable, Hashable, Codable {
    public static let joinLeadTime: TimeInterval = 60 * 60

    public let link: MeetingLink
    public let start: Date
    public let end: Date

    public init(link: MeetingLink, start: Date, end: Date) {
        self.link = link
        self.start = start
        self.end = end
    }

    init?(event: CalendarEvent) {
        guard let link = event.meetingLink else { return nil }
        self.init(link: link, start: event.startDate, end: event.endDate)
    }

    public func isJoinable(at date: Date) -> Bool {
        date >= start.addingTimeInterval(-Self.joinLeadTime) && date <= end
    }
}
