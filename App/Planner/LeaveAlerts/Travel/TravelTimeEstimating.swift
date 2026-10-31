import Foundation

public protocol TravelTimeEstimating: Sendable {
    func travelTime(
        from origin: PlannerCoordinate,
        to destination: PlannerCoordinate,
        by transport: TravelTransport,
        arrivingAt arrivalDate: Date
    ) async throws -> TimeInterval?
}
