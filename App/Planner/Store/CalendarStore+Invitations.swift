import Foundation

extension CalendarStore {
    public static let invitationLookahead: TimeInterval = 180 * 86400

    /// Reads the source directly so the long lookahead doesn't replace the cached window of the visible page.
    public func pendingInvitations(from start: Date = .now) async -> [CalendarEvent] {
        visiblePendingInvitations(in: await upcomingEvents(from: start))
    }

    public func hiddenInvitations(from start: Date = .now) async -> [CalendarEvent] {
        await upcomingEvents(from: start).hiddenInvitations(among: hiddenInvitationIdentifiers)
    }

    public func invitationCounts(from start: Date = .now) async -> InvitationCounts {
        let events = await upcomingEvents(from: start)
        return InvitationCounts(
            pending: visiblePendingInvitations(in: events).count,
            hidden: events.hiddenInvitations(among: hiddenInvitationIdentifiers).count
        )
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

    private func visiblePendingInvitations(in events: [CalendarEvent]) -> [CalendarEvent] {
        events.filter { !$0.isHiddenInvitation(among: hiddenInvitationIdentifiers) }.pendingInvitations()
    }

    private func upcomingEvents(from start: Date) async -> [CalendarEvent] {
        let interval = DateInterval(start: start, duration: Self.invitationLookahead)
        return await source.events(in: interval)
            .filter { !hiddenCalendarIdentifiers.contains($0.calendarIdentifier) }
    }
}
