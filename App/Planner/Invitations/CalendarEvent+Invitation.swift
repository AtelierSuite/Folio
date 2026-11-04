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

    /// Shared by every occurrence, and kept when a server sends the same invitation again.
    public var invitationIdentifier: String {
        reference.externalIdentifier ?? reference.localIdentifier
    }

    public var canHideInvitation: Bool {
        isPendingInvitation || isDeclined
    }

    /// Accepting a hidden invitation brings it back, since the event then matters again.
    public func isHiddenInvitation(among hiddenIdentifiers: Set<String>) -> Bool {
        canHideInvitation && hiddenIdentifiers.contains(invitationIdentifier)
    }

    public var attendeeSummary: AttendeeSummary {
        AttendeeSummary(attendees)
    }

    public var invitationCardStyle: InvitationCardStyle {
        InvitationCardStyle(userStatus: userStatus)
    }
}

extension Sequence where Element == CalendarEvent {
    public func pendingInvitations() -> [CalendarEvent] {
        filter(\.isPendingInvitation).firstOccurrencePerSeries()
    }

    public func hiddenInvitations(among hiddenIdentifiers: Set<String>) -> [CalendarEvent] {
        filter { $0.isHiddenInvitation(among: hiddenIdentifiers) }.firstOccurrencePerSeries()
    }

    /// Keeps one occurrence per series, since responding to one answers the whole invitation.
    private func firstOccurrencePerSeries() -> [CalendarEvent] {
        var seenSeries = Set<String>()
        return sorted { ($0.startDate, $0.title) < ($1.startDate, $1.title) }
            .filter { seenSeries.insert($0.invitationIdentifier).inserted }
    }
}
