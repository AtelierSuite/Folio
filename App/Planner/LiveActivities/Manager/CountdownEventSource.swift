import Foundation

@MainActor
public protocol CountdownEventSource: AnyObject {
    var canReadEvents: Bool { get }
    func countdownEvents(in interval: DateInterval) async -> [CalendarEvent]
    func isPendingRemoval(_ reference: CalendarItemReference) -> Bool
}

extension CalendarStore: CountdownEventSource {
    public var canReadEvents: Bool {
        eventAuthorization.allowsReading
    }

    /// Unlike `events(in:)`, keeps hidden calendars and leaves the visible interval alone.
    public func countdownEvents(in interval: DateInterval) async -> [CalendarEvent] {
        applyingPendingChanges(to: await repository.events(in: interval))
    }

    public func isPendingRemoval(_ reference: CalendarItemReference) -> Bool {
        pendingRemovals.values.contains { $0.hides(reference, kind: .event) }
    }
}
