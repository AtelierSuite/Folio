import Foundation

/// A cached geocode for one event's location text. A nil coordinate means MapKit found nothing for `query`,
/// or, with a `retryDate`, that the lookup failed and shouldn't be tried again before then.
public struct GeocodedLocation: Codable, Sendable, Hashable {
    public static let firstRetryDelay: TimeInterval = 15 * 60
    public static let longestRetryDelay: TimeInterval = 86_400

    public let query: String
    public let coordinate: PlannerCoordinate?
    public let failureCount: Int?
    public let retryDate: Date?

    public init(query: String, coordinate: PlannerCoordinate?) {
        self.query = query
        self.coordinate = coordinate
        failureCount = nil
        retryDate = nil
    }

    public static func failure(query: String, after previous: GeocodedLocation?, at date: Date) -> GeocodedLocation {
        let earlierFailures = previous?.query == query ? previous?.failureCount ?? 0 : 0
        let delay = min(firstRetryDelay * pow(2, Double(earlierFailures)), longestRetryDelay)
        return GeocodedLocation(
            query: query, failureCount: earlierFailures + 1, retryDate: date.addingTimeInterval(delay)
        )
    }

    private init(query: String, failureCount: Int, retryDate: Date) {
        self.query = query
        coordinate = nil
        self.failureCount = failureCount
        self.retryDate = retryDate
    }
}
