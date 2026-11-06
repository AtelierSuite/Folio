import Foundation

/// How long it takes to get to the next event from the event the user reached. The event's own time and
/// title are looked up when shown, so an edit to the event is picked up without working out the route again.
public struct LeaveByPlan: Sendable, Hashable, Codable {
    public let eventKey: String
    public let travelTime: TimeInterval
    public let transport: String

    public init(eventKey: String, travelTime: TimeInterval, transport: TravelTransport) {
        self.eventKey = eventKey
        self.travelTime = travelTime
        self.transport = transport.rawValue
    }

    public var travelTransport: TravelTransport {
        TravelTransport(rawValue: transport) ?? .driving
    }

    public func leaveDate(for event: CalendarEvent) -> Date {
        event.startDate.addingTimeInterval(-travelTime)
    }
}
