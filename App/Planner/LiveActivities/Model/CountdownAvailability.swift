import Foundation

public enum CountdownAvailability: Sendable, Hashable {
    case available(EventCountdownAttributes.ContentState)
    case notYet(availableFrom: Date)
    case unavailable

    public var state: EventCountdownAttributes.ContentState? {
        guard case .available(let state) = self else { return nil }
        return state
    }
}
