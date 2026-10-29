import Foundation

/// One continuous stretch of sleep (a night or a nap) after merging every source.
public struct SleepSession: Sendable, Hashable, Identifiable {
    public let segments: [SleepSegment]

    public init(segments: [SleepSegment]) {
        self.segments = segments.sorted { $0.interval.start < $1.interval.start }
    }

    public var id: Date { interval.start }

    public var interval: DateInterval {
        let start = segments.first?.interval.start ?? .distantPast
        let end = segments.map(\.interval.end).max() ?? start
        return DateInterval(start: start, end: end)
    }

    public var asleepDuration: TimeInterval {
        segments.filter(\.stage.isAsleep).reduce(0) { $0 + $1.interval.duration }
    }

    public var primarySource: SleepSource? {
        let durations = Dictionary(grouping: segments, by: \.source)
            .mapValues { $0.reduce(0) { $0 + $1.interval.duration } }
        return durations.max { $0.value < $1.value }?.key
    }
}
