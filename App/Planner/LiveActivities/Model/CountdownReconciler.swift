import Foundation

/// Works out how running countdowns should change after the calendar changed: follow a moved
/// or renamed event, end one whose event is gone or out of the window, and keep one per event.
public struct CountdownReconciler: Sendable {
    public let window: CountdownWindow

    public init(window: CountdownWindow = CountdownWindow()) {
        self.window = window
    }

    public func reconcile(
        _ running: [RunningCountdown],
        with events: [CalendarEvent],
        isPendingRemoval: (CalendarItemReference) -> Bool,
        now: Date
    ) -> [CountdownReconciliation] {
        var claimedKeys: Set<String> = []
        return running.compactMap { countdown in
            let reference = countdown.attributes.reference
            guard claimedKeys.insert(reference.storageKey).inserted else { return .end(id: countdown.id) }
            if isPendingRemoval(reference) { return nil }
            guard let match = reference.bestMatch(in: events.map(\.reference)),
                  let event = events.first(where: { $0.reference == match }),
                  let state = window.state(for: event, startedAt: countdown.attributes.startedAt, now: now) else {
                return .end(id: countdown.id)
            }
            return state == countdown.state ? nil : .update(id: countdown.id, state: state)
        }
    }

    /// Without calendar access only the clock can be trusted.
    public func endingFinished(_ running: [RunningCountdown], at now: Date) -> [CountdownReconciliation] {
        running.filter { now >= $0.state.finishDate }.map { .end(id: $0.id) }
    }

    /// The events a reconcile needs: anything that overlaps the next window.
    public func lookupInterval(at now: Date) -> DateInterval {
        DateInterval(start: now, duration: window.length)
    }
}
