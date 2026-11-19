import Foundation

public struct DirectionsDestination: Sendable, Hashable {
    public let name: String?
    public let coordinate: PlannerCoordinate?

    public init?(name: String?, coordinate: PlannerCoordinate?) {
        let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        let usableName = trimmed.flatMap { $0.isEmpty ? nil : $0 }
        guard usableName != nil || coordinate != nil else { return nil }
        self.name = usableName
        self.coordinate = coordinate
    }
}
