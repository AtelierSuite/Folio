import Foundation

extension CalendarEvent {
    public var isInvitation: Bool {
        userStatus != nil
    }

    public var isPendingInvitation: Bool {
        userStatus?.response == .pending
    }

    public var isDeclined: Bool {
        userStatus?.response == .declined
    }

    public var attendeeSummary: AttendeeSummary {
        AttendeeSummary(attendees)
    }

    public var invitationCardStyle: InvitationCardStyle {
        InvitationCardStyle(userStatus: userStatus)
    }
}

extension Sequence where Element == CalendarEvent {
    /// Keeps one occurrence per series, since responding to one answers the whole invitation.
    public func pendingInvitations() -> [CalendarEvent] {
        var seenSeries = Set<String>()
        return filter(\.isPendingInvitation)
            .sorted { ($0.startDate, $0.title) < ($1.startDate, $1.title) }
            .filter { seenSeries.insert($0.reference.externalIdentifier ?? $0.reference.localIdentifier).inserted }
    }
}
