import Foundation

/// The time already claimed by higher priority samples, kept sorted and non-overlapping.
struct SleepCoverage {
    private(set) var intervals: [DateInterval] = []

    func uncovered(_ interval: DateInterval) -> [DateInterval] {
        var pieces: [DateInterval] = []
        var cursor = interval.start
        for covered in intervals where covered.end > cursor && covered.start < interval.end {
            if covered.start > cursor {
                pieces.append(DateInterval(start: cursor, end: covered.start))
            }
            cursor = max(cursor, covered.end)
        }
        if cursor < interval.end {
            pieces.append(DateInterval(start: cursor, end: interval.end))
        }
        return pieces
    }

    mutating func insert(_ interval: DateInterval) {
        var merged = interval
        var remaining: [DateInterval] = []
        for covered in intervals {
            if covered.end < merged.start || covered.start > merged.end {
                remaining.append(covered)
            } else {
                merged = DateInterval(start: min(covered.start, merged.start), end: max(covered.end, merged.end))
            }
        }
        remaining.append(merged)
        intervals = remaining.sorted { $0.start < $1.start }
    }
}
