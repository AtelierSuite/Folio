import Foundation

/// A coordinate snapped to a 0.1° grid (about 11 km), so nearby places share one cache entry.
public struct WeatherLocationKey: Sendable, Hashable, Codable {
    public static let stepsPerDegree = 10.0

    public let latitudeSteps: Int
    public let longitudeSteps: Int

    public init(_ coordinate: PlannerCoordinate) {
        let latitude = min(max(coordinate.latitude, -90), 90)
        var longitude = coordinate.longitude.truncatingRemainder(dividingBy: 360)
        if longitude >= 180 { longitude -= 360 }
        if longitude < -180 { longitude += 360 }
        latitudeSteps = Int((latitude * Self.stepsPerDegree).rounded())
        var roundedLongitude = Int((longitude * Self.stepsPerDegree).rounded())
        if roundedLongitude == Int(180 * Self.stepsPerDegree) {
            roundedLongitude = -roundedLongitude
        }
        longitudeSteps = roundedLongitude
    }

    public var coordinate: PlannerCoordinate {
        PlannerCoordinate(
            latitude: Double(latitudeSteps) / Self.stepsPerDegree,
            longitude: Double(longitudeSteps) / Self.stepsPerDegree
        )
    }

    public var pathComponent: String {
        String(format: "%.1f_%.1f", coordinate.latitude, coordinate.longitude)
    }
}
