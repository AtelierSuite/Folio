import Foundation

public struct CountdownPhases: Sendable, Hashable {
    public var countsToStart: Bool
    public var countsToEnd: Bool

    public init(countsToStart: Bool = true, countsToEnd: Bool = true) {
        self.countsToStart = countsToStart
        self.countsToEnd = countsToEnd
    }
}
