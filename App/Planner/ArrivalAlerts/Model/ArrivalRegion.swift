import Foundation

public struct ArrivalRegion: Sendable, Hashable, Identifiable {
    public static let identifierPrefix = "folio.arrival."

    public let id: String
    public let coordinate: PlannerCoordinate
    public let radius: Double
    public let candidates: [ArrivalCandidate]

    public init(coordinate: PlannerCoordinate, radius: Double, candidates: [ArrivalCandidate]) {
        self.id = Self.identifier(for: coordinate)
        self.coordinate = coordinate
        self.radius = radius
        self.candidates = candidates
    }

    public static func identifier(for coordinate: PlannerCoordinate) -> String {
        let latitude = String(format: "%.4f", coordinate.latitude)
        let longitude = String(format: "%.4f", coordinate.longitude)
        return "\(identifierPrefix)\(latitude)_\(longitude)"
    }

    public func candidates(arrivingAt date: Date) -> [ArrivalCandidate] {
        candidates.filter { $0.window.contains(date) }
    }
}
