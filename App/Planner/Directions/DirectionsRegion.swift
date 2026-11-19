import Foundation

/// A rough box around the area a regional maps app can route in.
struct DirectionsRegion: Sendable {
    let latitudes: ClosedRange<Double>
    let longitudes: ClosedRange<Double>

    func contains(_ coordinate: PlannerCoordinate) -> Bool {
        latitudes.contains(coordinate.latitude) && longitudes.contains(coordinate.longitude)
    }

    static let japan = DirectionsRegion(latitudes: 20...46, longitudes: 122...154)
    /// The range NAVER Map accepts for a destination.
    static let korea = DirectionsRegion(latitudes: 31.43...44.35, longitudes: 122.37...132.0)
}

extension DirectionsDestination {
    /// `false` only when the coordinate is known and outside the region.
    func mayBe(in region: DirectionsRegion) -> Bool {
        coordinate.map(region.contains) ?? true
    }
}
