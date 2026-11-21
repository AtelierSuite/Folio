import Foundation

public struct SavedArrivalCandidate: Codable, Sendable, Hashable {
    public let reference: CalendarItemReference
    public let coordinate: PlannerCoordinate
    public let window: DateInterval

    public init(_ candidate: ArrivalCandidate) {
        reference = candidate.event.reference
        coordinate = candidate.coordinate
        window = candidate.window
    }
}
