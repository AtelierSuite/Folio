import Foundation
import Testing
@testable import Planner

@MainActor
struct EventCountdownManagerTests {
    private let controller = FakeCountdownController()
    private let source = FakeCountdownEventSource()
    /// Far enough ahead that the manager's real-clock finish timer never fires mid-test.
    private let start = Fixtures.date(2036, 10, 29, hour: 18)
    private var now: Date { start.addingTimeInterval(-3600) }

    private func makeManager() -> EventCountdownManager {
        EventCountdownManager(source: source, controller: controller)
    }

    @Test func startsOneCountdownPerEvent() throws {
        let manager = makeManager()
        let event = Fixtures.countdownEvent(local: "dinner", start: start)
        try manager.start(event, at: now)
        #expect(manager.isCountingDown(event))
        #expect(throws: CountdownActivityError.alreadyRunning) { try manager.start(event, at: now) }
        #expect(controller.runningCountdowns.count == 1)
    }

    @Test func refusesToStartOutsideTheWindow() {
        let manager = makeManager()
        let event = Fixtures.countdownEvent(local: "dinner", start: start)
        #expect(throws: CountdownActivityError.outsideWindow) {
            try manager.start(event, at: start.addingTimeInterval(-9 * 3600))
        }
    }

    @Test func stopEndsTheEventsCountdown() async throws {
        let manager = makeManager()
        let event = Fixtures.countdownEvent(local: "dinner", start: start)
        try manager.start(event, at: now)
        await manager.stop(event)
        #expect(!manager.isCountingDown(event))
    }

    @Test func reconcileFollowsAMoveAndEndsADelete() async throws {
        let manager = makeManager()
        let dinner = Fixtures.countdownEvent(local: "dinner", start: start)
        let lunch = Fixtures.countdownEvent(local: "lunch", start: start)
        try manager.start(dinner, at: now)
        try manager.start(lunch, at: now)
        let movedDinner = Fixtures.countdownEvent(local: "dinner", start: start.addingTimeInterval(1800))
        source.events = [movedDinner]
        await manager.reconcile(at: now)
        #expect(manager.running.map(\.state.startDate) == [movedDinner.startDate])
        #expect(manager.isCountingDown(movedDinner))
        #expect(!manager.isCountingDown(lunch))
    }

    @Test func reconcileWaitsForAnUndoableDelete() async throws {
        let manager = makeManager()
        let event = Fixtures.countdownEvent(local: "dinner", start: start)
        try manager.start(event, at: now)
        source.pendingRemovalIdentifiers = ["dinner"]
        await manager.reconcile(at: now)
        #expect(manager.isCountingDown(event))
        source.pendingRemovalIdentifiers = []
        await manager.reconcile(at: now)
        #expect(!manager.isCountingDown(event))
    }

    @Test func reconcileWithoutAccessKeepsUpcomingCountdowns() async throws {
        let manager = makeManager()
        let event = Fixtures.countdownEvent(local: "dinner", start: start)
        try manager.start(event, at: now)
        source.canReadEvents = false
        await manager.reconcile(at: now)
        #expect(manager.isCountingDown(event))
    }

    @Test func startNextCountdownPicksTheSoonestEvent() async throws {
        let manager = makeManager()
        source.events = [
            Fixtures.countdownEvent(local: "later", start: start.addingTimeInterval(3600)),
            Fixtures.countdownEvent(local: "dinner", start: start)
        ]
        let started = try await manager.startNextCountdown(at: now)
        #expect(started.title == "dinner")
        source.events = []
        await #expect(throws: CountdownActivityError.noUpcomingEvent) { try await manager.startNextCountdown(at: now) }
    }
}
