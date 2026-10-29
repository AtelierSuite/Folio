import Foundation

public struct ArrivalCandidate: Sendable, Hashable {
    public let event: CalendarEvent
    public let coordinate: PlannerCoordinate
    public let window: DateInterval

    public init(event: CalendarEvent, coordinate: PlannerCoordinate, window: DateInterval) {
        self.event = event
        self.coordinate = coordinate
        self.window = window
    }
}
