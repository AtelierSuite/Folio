import Foundation

public struct WeatherLocationFix: Sendable, Hashable, Codable {
    public let coordinate: PlannerCoordinate
    public let date: Date

    public init(coordinate: PlannerCoordinate, date: Date) {
        self.coordinate = coordinate
        self.date = date
    }
}
