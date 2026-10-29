import Foundation

public protocol LocationGeocoding: Sendable {
    func coordinate(for address: String) async throws -> PlannerCoordinate?
}
