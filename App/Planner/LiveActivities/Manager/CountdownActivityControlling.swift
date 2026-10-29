import Foundation

/// Starts, updates and ends the system activities behind event countdowns.
@MainActor
public protocol CountdownActivityControlling: AnyObject {
    var runningCountdowns: [RunningCountdown] { get }
    func start(_ attributes: EventCountdownAttributes, state: EventCountdownAttributes.ContentState) throws
    func update(id: String, state: EventCountdownAttributes.ContentState) async
    func end(id: String) async
}

public enum CountdownActivityError: Error, Sendable {
    case unsupported
    case alreadyRunning
    case outsideWindow
    case noUpcomingEvent
}
