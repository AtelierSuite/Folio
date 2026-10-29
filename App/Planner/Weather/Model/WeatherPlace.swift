import Foundation

public struct WeatherPlace: Sendable, Hashable, Codable {
    public let name: String
    public let coordinate: PlannerCoordinate

    public init(name: String, coordinate: PlannerCoordinate) {
        self.name = name
        self.coordinate = coordinate
    }
}
