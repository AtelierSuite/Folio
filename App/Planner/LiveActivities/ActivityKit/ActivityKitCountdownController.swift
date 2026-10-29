#if os(iOS)
import ActivityKit
import Foundation

/// The stale date is when the countdown reaches zero, which makes the system redraw the
/// activity then, so it can switch to "ends in…" or "started" without an update from the app.
@MainActor
final class ActivityKitCountdownController: CountdownActivityControlling {
    var runningCountdowns: [RunningCountdown] {
        Activity<EventCountdownAttributes>.activities
            .filter { $0.activityState == .active || $0.activityState == .stale }
            .map { RunningCountdown(id: $0.id, attributes: $0.attributes, state: $0.content.state) }
    }

    func start(_ attributes: EventCountdownAttributes, state: EventCountdownAttributes.ContentState) throws {
        _ = try Activity.request(attributes: attributes, content: content(for: state), pushType: nil)
    }

    func update(id: String, state: EventCountdownAttributes.ContentState) async {
        await Self.update(id: id, content: content(for: state))
    }

    func end(id: String) async {
        await Self.end(id: id)
    }

    private nonisolated static func update(
        id: String,
        content: ActivityContent<EventCountdownAttributes.ContentState>
    ) async {
        await activity(withID: id)?.update(content)
    }

    private nonisolated static func end(id: String) async {
        await activity(withID: id)?.end(nil, dismissalPolicy: .immediate)
    }

    private nonisolated static func activity(withID id: String) -> Activity<EventCountdownAttributes>? {
        Activity<EventCountdownAttributes>.activities.first { $0.id == id }
    }

    private func content(
        for state: EventCountdownAttributes.ContentState
    ) -> ActivityContent<EventCountdownAttributes.ContentState> {
        ActivityContent(state: state, staleDate: state.startDate, relevanceScore: 1)
    }
}
#endif
