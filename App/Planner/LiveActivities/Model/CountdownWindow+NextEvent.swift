import Foundation

extension CountdownWindow {
    /// The soonest event that hasn't started yet and can be counted down to now.
    public func nextEvent(in events: [CalendarEvent], at now: Date) -> CalendarEvent? {
        events
            .filter { $0.startDate > now && availability(for: $0, at: now).state != nil }
            .min { $0.startDate < $1.startDate }
    }
}
