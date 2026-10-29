import Foundation
import MapKit

public struct MapKitLocationGeocoder: LocationGeocoding {
    public init() {}

    public func coordinate(for address: String) async throws -> PlannerCoordinate? {
        guard let request = MKGeocodingRequest(addressString: address) else { return nil }
        guard let location = try await request.mapItems.first?.location else { return nil }
        return PlannerCoordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
}
