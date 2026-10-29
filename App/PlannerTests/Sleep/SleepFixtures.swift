import Foundation
@testable import Planner

enum SleepFixtures {
    static let watch = SleepSource(id: "com.apple.health.watch", name: "Apple Watch", kind: .watch)
    static let phone = SleepSource(id: "com.apple.health.phone", name: "iPhone", kind: .phone)
    static let ring = SleepSource(id: "com.example.ring", name: "Ring", kind: .other)
    static let tracker = SleepSource(id: "com.example.tracker", name: "Tracker", kind: .other)

    /// 2026-10-29 at the given hour and minute (UTC). Hours below 12 are the morning after a night
    /// starting on the 28th, so pass `night: true` for evening times on the 28th.
    static func time(_ hour: Int, _ minute: Int = 0, night: Bool = false) -> Date {
        let day = night ? 28 : 29
        return Fixtures.calendar.date(
            from: DateComponents(year: 2026, month: 10, day: day, hour: hour, minute: minute)
        ) ?? .distantPast
    }

    static func sample(_ stage: SleepStage, _ start: Date, _ end: Date, _ source: SleepSource) -> SleepSample {
        SleepSample(stage: stage, interval: DateInterval(start: start, end: end), source: source)
    }
}

struct SegmentSummary: Equatable, CustomStringConvertible {
    let stage: SleepStage
    let start: Date
    let end: Date
    let sourceIdentifier: String

    init(_ stage: SleepStage, _ start: Date, _ end: Date, _ source: SleepSource) {
        self.stage = stage
        self.start = start
        self.end = end
        sourceIdentifier = source.id
    }

    init(_ segment: SleepSegment) {
        stage = segment.stage
        start = segment.interval.start
        end = segment.interval.end
        sourceIdentifier = segment.source.id
    }

    var description: String {
        "\(stage) \(start.formatted(.iso8601))–\(end.formatted(.iso8601)) \(sourceIdentifier)"
    }
}
