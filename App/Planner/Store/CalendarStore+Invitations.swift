import Foundation

extension CalendarStore {
    public static let invitationLookahead: TimeInterval = 180 * 86400

    /// Reads the source directly so the long lookahead doesn't replace the cached window of the visible page.
    public func pendingInvitations(from start: Date = .now) async -> [CalendarEvent] {
        let interval = DateInterval(start: start, duration: Self.invitationLookahead)
        return await source.events(in: interval)
            .filter { !hiddenCalendarIdentifiers.contains($0.calendarIdentifier) }
            .pendingInvitations()
    }
}
