import Foundation

extension EventCountdownManager {
    /// Follows calendar changes made since the countdowns started. Run at launch and whenever
    /// the store's content changes; a delete waiting on its undo toast keeps its countdown.
    public func reconcile(at now: Date = .now) async {
        let countdowns = controller.runningCountdowns
        let changes: [CountdownReconciliation]
        if !countdowns.isEmpty && source.canReadEvents {
            let events = await source.countdownEvents(in: reconciler.lookupInterval(at: now))
            changes = reconciler.reconcile(
                countdowns, with: events, isPendingRemoval: source.isPendingRemoval, now: now
            )
        } else {
            changes = reconciler.endingFinished(countdowns, at: now)
        }
        for change in changes {
            switch change {
            case .update(let id, let state):
                await controller.update(id: id, state: state)
            case .end(let id):
                await controller.end(id: id)
            }
        }
        refresh()
    }

    /// For Siri and Shortcuts: counts down to the next event the window allows.
    @discardableResult
    public func startNextCountdown(at now: Date = .now) async throws -> CalendarEvent {
        guard source.canReadEvents else { throw CountdownActivityError.noUpcomingEvent }
        let events = await source.countdownEvents(in: reconciler.lookupInterval(at: now))
        guard let event = window.nextEvent(in: events, at: now) else { throw CountdownActivityError.noUpcomingEvent }
        if !isCountingDown(event) {
            try start(event, at: now)
        }
        return event
    }
}
