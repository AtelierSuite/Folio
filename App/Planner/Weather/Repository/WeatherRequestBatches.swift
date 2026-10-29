import Foundation

enum WeatherRequestBatches {
    /// Groups days into runs of consecutive days, at most `maximumDays` long, so each run is one request.
    static func batches(for days: [DateInterval], maximumDays: Int) -> [[DateInterval]] {
        let sorted = Set(days).sorted { $0.start < $1.start }
        var batches: [[DateInterval]] = []
        for day in sorted {
            if let last = batches.last?.last, last.end == day.start, batches[batches.count - 1].count < maximumDays {
                batches[batches.count - 1].append(day)
            } else {
                batches.append([day])
            }
        }
        return batches
    }
}
