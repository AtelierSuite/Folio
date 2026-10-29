import Foundation

public enum CountdownReconciliation: Sendable, Hashable {
    case update(id: String, state: EventCountdownAttributes.ContentState)
    case end(id: String)
}
