import CoreLocation
import Foundation
import MapKit

public struct MapKitTravelTimeEstimator: TravelTimeEstimating {
    public init() {}

    public func travelTime(
        from origin: PlannerCoordinate,
        to destination: PlannerCoordinate,
        by transport: TravelTransport,
        arrivingAt arrivalDate: Date
    ) async throws -> TimeInterval? {
        let request = MKDirections.Request()
        request.source = MKMapItem(location: CLLocation(origin), address: nil)
        request.destination = MKMapItem(location: CLLocation(destination), address: nil)
        request.transportType = MKDirectionsTransportType(transport)
        request.arrivalDate = arrivalDate
        return try await MKDirections(request: request).calculateETA().expectedTravelTime
    }
}

private extension CLLocation {
    convenience init(_ coordinate: PlannerCoordinate) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

private extension MKDirectionsTransportType {
    init(_ transport: TravelTransport) {
        switch transport {
        case .driving: self = .automobile
        case .walking: self = .walking
        case .transit: self = .transit
        }
    }
}
