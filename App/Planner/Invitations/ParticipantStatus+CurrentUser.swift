import Foundation

extension ParticipantStatus {
    public static func currentUserStatus(
        organizer: EventParticipant?,
        attendees: [EventParticipant]
    ) -> ParticipantStatus? {
        if organizer?.isCurrentUser == true { return nil }
        return attendees.first(where: \.isCurrentUser)?.status
    }
}
