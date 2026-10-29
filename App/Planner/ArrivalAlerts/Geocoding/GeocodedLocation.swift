import Foundation

/// A cached geocode for one event's location text. A nil coordinate means MapKit found nothing for `query`.
public struct GeocodedLocation: Codable, Sendable, Hashable {
    public let query: String
    public let coordinate: PlannerCoordinate?

    public init(query: String, coordinate: PlannerCoordinate?) {
        self.query = query
        self.coordinate = coordinate
    }
}
