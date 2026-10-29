import Foundation

@MainActor
final class UnavailableCountdownController: CountdownActivityControlling {
    var runningCountdowns: [RunningCountdown] { [] }

    func start(_ attributes: EventCountdownAttributes, state: EventCountdownAttributes.ContentState) throws {
        throw CountdownActivityError.unsupported
    }

    func update(id: String, state: EventCountdownAttributes.ContentState) async {}

    func end(id: String) async {}
}
