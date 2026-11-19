import Foundation

/// The rough area a regional maps app can route in, as a set of boxes.
struct DirectionsRegion: Sendable {
    struct Box: Sendable {
        let latitudes: ClosedRange<Double>
        let longitudes: ClosedRange<Double>
    }

    let boxes: [Box]

    func contains(_ coordinate: PlannerCoordinate) -> Bool {
        boxes.contains { $0.latitudes.contains(coordinate.latitude) && $0.longitudes.contains(coordinate.longitude) }
    }

    /// Drawn around Japan's coastline so that Korea, Taiwan and the Russian Far East fall outside it.
    static let japan = DirectionsRegion(boxes: [
        Box(latitudes: 41.3...45.6, longitudes: 139.3...146.0),
        Box(latitudes: 33.0...41.6, longitudes: 131.5...142.2),
        Box(latitudes: 30.9...34.75, longitudes: 128.5...132.0),
        Box(latitudes: 24.0...30.9, longitudes: 122.9...131.5),
        Box(latitudes: 20.0...30.0, longitudes: 136.0...154.0)
    ])

    /// The range NAVER Map accepts for a destination.
    static let korea = DirectionsRegion(boxes: [
        Box(latitudes: 31.43...44.35, longitudes: 122.37...132.0)
    ])
}

extension DirectionsDestination {
    /// `false` only when the coordinate is known and outside the region.
    func mayBe(in region: DirectionsRegion) -> Bool {
        coordinate.map(region.contains) ?? true
    }
}
