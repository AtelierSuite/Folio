import Foundation

/// Offline or over quota, WeatherKit keeps failing, so a location that just failed isn't asked again
/// until a delay that doubles with each failure has passed.
struct WeatherFailureBackoff: Sendable {
    private struct Failure: Sendable {
        var count: Int
        var retryAt: Date
    }

    var initialDelay: TimeInterval = 120
    var maximumDelay: TimeInterval = 1800
    private var failures: [WeatherLocationKey: Failure] = [:]

    func allowsFetch(at location: WeatherLocationKey, now: Date) -> Bool {
        guard let failure = failures[location] else { return true }
        return now >= failure.retryAt
    }

    mutating func recordFailure(at location: WeatherLocationKey, now: Date) {
        let count = (failures[location]?.count ?? 0) + 1
        let delay = min(initialDelay * pow(2, Double(count - 1)), maximumDelay)
        failures[location] = Failure(count: count, retryAt: now.addingTimeInterval(delay))
    }

    mutating func recordSuccess(at location: WeatherLocationKey) {
        failures[location] = nil
    }
}
