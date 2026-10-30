import Foundation

/// An unbroken run of segments in a session, regardless of stage.
public struct SleepStretch: Sendable, Hashable {
    public let interval: DateInterval
    public let isAsleep: Bool

    public init(interval: DateInterval, isAsleep: Bool) {
        self.interval = interval
        self.isAsleep = isAsleep
    }
}

extension SleepSession {
    public var stretches: [SleepStretch] {
        var stretches: [SleepStretch] = []
        for segment in segments {
            if let last = stretches.last, segment.interval.start <= last.interval.end {
                stretches[stretches.count - 1] = SleepStretch(
                    interval: DateInterval(
                        start: last.interval.start,
                        end: max(last.interval.end, segment.interval.end)
                    ),
                    isAsleep: last.isAsleep || segment.stage.isAsleep
                )
            } else {
                stretches.append(SleepStretch(interval: segment.interval, isAsleep: segment.stage.isAsleep))
            }
        }
        return stretches
    }
}
