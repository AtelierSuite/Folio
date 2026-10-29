import Foundation
@testable import Planner

@MainActor
final class FakeCountdownController: CountdownActivityControlling {
    var runningCountdowns: [RunningCountdown] = []
    private(set) var endedIdentifiers: [String] = []
    private var nextIdentifier = 0

    func start(_ attributes: EventCountdownAttributes, state: EventCountdownAttributes.ContentState) throws {
        nextIdentifier += 1
        let countdown = RunningCountdown(id: "activity-\(nextIdentifier)", attributes: attributes, state: state)
        runningCountdowns.append(countdown)
    }

    func update(id: String, state: EventCountdownAttributes.ContentState) async {
        guard let index = runningCountdowns.firstIndex(where: { $0.id == id }) else { return }
        let countdown = runningCountdowns[index]
        runningCountdowns[index] = RunningCountdown(id: id, attributes: countdown.attributes, state: state)
    }

    func end(id: String) async {
        runningCountdowns.removeAll { $0.id == id }
        endedIdentifiers.append(id)
    }
}

@MainActor
final class FakeCountdownEventSource: CountdownEventSource {
    var canReadEvents = true
    var events: [CalendarEvent] = []
    var pendingRemovalIdentifiers: Set<String> = []

    func countdownEvents(in interval: DateInterval) async -> [CalendarEvent] {
        events.filter { $0.overlaps(interval) }
    }

    func isPendingRemoval(_ reference: CalendarItemReference) -> Bool {
        pendingRemovalIdentifiers.contains(reference.localIdentifier)
    }
}
