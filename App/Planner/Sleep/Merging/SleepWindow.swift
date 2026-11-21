import Foundation

public enum SleepWindow {
    /// Sleep that ended this morning usually started the evening before, so last night reaches back to noon yesterday.
    public static func lastNight(now: Date, calendar: Calendar) -> DateInterval {
        let startOfToday = calendar.startOfDay(for: now)
        let start = calendar.date(byAdding: .hour, value: -12, to: startOfToday) ?? startOfToday
        return DateInterval(start: start, end: max(now, start))
    }

    /// Widens a visible span so nights crossing its edges are fetched whole.
    public static func fetchInterval(covering span: DateInterval, margin: TimeInterval = 18 * 3600) -> DateInterval {
        DateInterval(start: span.start.addingTimeInterval(-margin), end: span.end.addingTimeInterval(margin))
    }

    private static let blockDuration: TimeInterval = 7 * 86_400

    /// Sleep is read in fixed weeks, so neighbouring pages share reads instead of each asking for its own span.
    static func blocks(covering interval: DateInterval) -> ClosedRange<Int> {
        let first = Int((interval.start.timeIntervalSinceReferenceDate / blockDuration).rounded(.down))
        let last = Int((interval.end.timeIntervalSinceReferenceDate / blockDuration).rounded(.up)) - 1
        return first...max(first, last)
    }

    static func interval(ofBlock block: Int) -> DateInterval {
        DateInterval(
            start: Date(timeIntervalSinceReferenceDate: Double(block) * blockDuration),
            duration: blockDuration
        )
    }
}
