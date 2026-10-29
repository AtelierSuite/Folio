import Foundation

/// Merges overlapping sleep samples from every source into one timeline. Sleep stages win over
/// time in bed, and where sources overlap the higher ranked source wins.
public struct SleepMerger: Sendable {
    public let ranking: SleepSourceRanking
    public let sessionGap: TimeInterval

    public init(ranking: SleepSourceRanking = SleepSourceRanking(), sessionGap: TimeInterval = 2 * 3600) {
        self.ranking = ranking
        self.sessionGap = sessionGap
    }

    public func segments(from samples: [SleepSample]) -> [SleepSegment] {
        var coverage = SleepCoverage()
        var segments: [SleepSegment] = []
        for sample in prioritized(samples) {
            for piece in coverage.uncovered(sample.interval) {
                segments.append(SleepSegment(stage: sample.stage, interval: piece, source: sample.source))
            }
            coverage.insert(sample.interval)
        }
        return coalesced(segments)
    }

    public func sessions(from samples: [SleepSample]) -> [SleepSession] {
        var sessions: [[SleepSegment]] = []
        var sessionEnd = Date.distantPast
        for segment in segments(from: samples) {
            if !sessions.isEmpty, segment.interval.start.timeIntervalSince(sessionEnd) <= sessionGap {
                sessions[sessions.count - 1].append(segment)
            } else {
                sessions.append([segment])
            }
            sessionEnd = max(sessionEnd, segment.interval.end)
        }
        return sessions.map(SleepSession.init(segments:))
    }

    private func prioritized(_ samples: [SleepSample]) -> [SleepSample] {
        samples
            .filter { $0.interval.duration > 0 }
            .sorted { lhs, rhs in
                let lhsInBed = lhs.stage == .inBed
                let rhsInBed = rhs.stage == .inBed
                if lhsInBed != rhsInBed { return rhsInBed }
                if lhs.source != rhs.source { return ranking.isRankedHigher(lhs.source, than: rhs.source) }
                return lhs.interval.start < rhs.interval.start
            }
    }

    private func coalesced(_ segments: [SleepSegment]) -> [SleepSegment] {
        var result: [SleepSegment] = []
        for segment in segments.sorted(by: { $0.interval.start < $1.interval.start }) {
            if let last = result.last, last.stage == segment.stage, last.source == segment.source,
               last.interval.end == segment.interval.start {
                result[result.count - 1] = SleepSegment(
                    stage: last.stage,
                    interval: DateInterval(start: last.interval.start, end: segment.interval.end),
                    source: last.source
                )
            } else {
                result.append(segment)
            }
        }
        return result
    }
}
