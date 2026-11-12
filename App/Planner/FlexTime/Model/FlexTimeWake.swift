import Foundation

public struct FlexTimeWake: Sendable, Hashable {
    public enum Source: Sendable, Hashable {
        case sleep
        case firstOpen
    }

    public let time: Date
    public let source: Source

    public init(time: Date, source: Source) {
        self.time = time
        self.source = source
    }
}
