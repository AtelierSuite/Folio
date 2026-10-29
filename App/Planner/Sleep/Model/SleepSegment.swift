import Foundation

public struct SleepSegment: Sendable, Hashable {
    public let stage: SleepStage
    public let interval: DateInterval
    public let source: SleepSource

    public init(stage: SleepStage, interval: DateInterval, source: SleepSource) {
        self.stage = stage
        self.interval = interval
        self.source = source
    }
}
