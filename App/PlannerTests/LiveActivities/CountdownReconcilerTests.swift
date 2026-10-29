import Foundation
import Testing
@testable import Planner

struct CountdownReconcilerTests {
    private let reconciler = CountdownReconciler()
    private let start = Fixtures.date(2026, 10, 29, hour: 18)
    private var now: Date { start.addingTimeInterval(-3 * 3600) }

    private func countdown(id: String, for event: CalendarEvent, startedAt: Date? = nil) -> RunningCountdown {
        let startedAt = startedAt ?? now
        let state = CountdownWindow().state(for: event, startedAt: startedAt, now: startedAt)
        return RunningCountdown(
            id: id,
            attributes: EventCountdownAttributes(reference: event.reference, startedAt: startedAt),
            state: state ?? EventCountdownAttributes.ContentState(
                title: event.title, location: nil, color: .gray, startDate: event.startDate, endDate: nil
            )
        )
    }

    private func reconcile(_ running: [RunningCountdown], events: [CalendarEvent], pending: Bool = false) -> [CountdownReconciliation] {
        reconciler.reconcile(running, with: events, isPendingRemoval: { _ in pending }, now: now)
    }

    @Test func unchangedEventNeedsNothing() {
        let event = Fixtures.countdownEvent(local: "dinner", start: start)
        #expect(reconcile([countdown(id: "one", for: event)], events: [event]).isEmpty)
    }

    @Test func movedEventUpdatesTheCountdown() {
        let event = Fixtures.countdownEvent(local: "dinner", start: start)
        let moved = Fixtures.countdownEvent(local: "dinner", start: start.addingTimeInterval(1800))
        let changes = reconcile([countdown(id: "one", for: event)], events: [moved])
        #expect(changes == [.update(id: "one", state: CountdownWindow().state(for: moved, startedAt: now, now: now)!)])
    }

    @Test func deletedEventEndsTheCountdown() {
        let event = Fixtures.countdownEvent(local: "dinner", start: start)
        let other = Fixtures.countdownEvent(local: "lunch", start: start)
        #expect(reconcile([countdown(id: "one", for: event)], events: [other]) == [.end(id: "one")])
    }

    @Test func deleteAwaitingUndoKeepsTheCountdown() {
        let event = Fixtures.countdownEvent(local: "dinner", start: start)
        #expect(reconcile([countdown(id: "one", for: event)], events: [], pending: true).isEmpty)
    }

    @Test func duplicateCountdownsForOneEventEndTheExtras() {
        let event = Fixtures.countdownEvent(local: "dinner", start: start)
        let changes = reconcile([countdown(id: "one", for: event), countdown(id: "two", for: event)], events: [event])
        #expect(changes == [.end(id: "two")])
    }

    @Test func movedOutOfTheWindowEndsTheCountdown() {
        let event = Fixtures.countdownEvent(local: "dinner", start: start)
        let moved = Fixtures.countdownEvent(local: "dinner", start: start.addingTimeInterval(8 * 3600))
        #expect(reconcile([countdown(id: "one", for: event)], events: [moved]) == [.end(id: "one")])
    }

    @Test func withoutAccessOnlyFinishedCountdownsEnd() {
        let lunch = Fixtures.countdownEvent(local: "lunch", start: now.addingTimeInterval(-60), hours: 0)
        let finished = countdown(id: "one", for: lunch, startedAt: now.addingTimeInterval(-3600))
        let upcoming = countdown(id: "two", for: Fixtures.countdownEvent(local: "dinner", start: start))
        #expect(reconciler.endingFinished([finished, upcoming], at: now) == [.end(id: "one")])
    }
}
