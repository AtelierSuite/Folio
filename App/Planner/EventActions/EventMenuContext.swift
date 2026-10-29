import Foundation

/// What the menu needs to know beyond the event itself.
public struct EventMenuContext: Sendable {
    public var eventCalendar: PlannerCalendar?
    public var writableCalendars: [PlannerCalendar]
    public var hasLinkedNote: Bool
    /// Whether a countdown could start now, which the 8-hour `CountdownWindow` decides.
    public var canStartCountdown: Bool
    public var isCountingDown: Bool
    public var canRespondToInvitations: Bool

    public init(
        eventCalendar: PlannerCalendar?,
        writableCalendars: [PlannerCalendar],
        hasLinkedNote: Bool,
        canStartCountdown: Bool = false,
        isCountingDown: Bool = false,
        canRespondToInvitations: Bool = false
    ) {
        self.eventCalendar = eventCalendar
        self.writableCalendars = writableCalendars
        self.hasLinkedNote = hasLinkedNote
        self.canStartCountdown = canStartCountdown
        self.isCountingDown = isCountingDown
        self.canRespondToInvitations = canRespondToInvitations
    }
}
