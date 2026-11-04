import Foundation

extension CalendarStore {
    public static let invitationLookahead: TimeInterval = 180 * 86400

    /// Reads the source directly so the long lookahead doesn't replace the cached window of the visible page.
    public func pendingInvitations(from start: Date = .now) async -> [CalendarEvent] {
        await upcomingEvents(from: start)
            .filter { !$0.isHiddenInvitation(among: hiddenInvitationIdentifiers) }
            .pendingInvitations()
    }

    public func hiddenInvitations(from start: Date = .now) async -> [CalendarEvent] {
        await upcomingEvents(from: start).hiddenInvitations(among: hiddenInvitationIdentifiers)
    }

    public func setHidden(_ isHidden: Bool, invitation: CalendarEvent) {
        if isHidden {
            hiddenInvitationIdentifiers.insert(invitation.invitationIdentifier)
        } else {
            hiddenInvitationIdentifiers.remove(invitation.invitationIdentifier)
        }
        visibilityStorage.hiddenInvitationIdentifiers = hiddenInvitationIdentifiers
        contentRevision += 1
    }

    private func upcomingEvents(from start: Date) async -> [CalendarEvent] {
        let interval = DateInterval(start: start, duration: Self.invitationLookahead)
        return await source.events(in: interval)
            .filter { !hiddenCalendarIdentifiers.contains($0.calendarIdentifier) }
    }
}
