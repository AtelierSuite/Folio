import Foundation

/// How long it takes to reach an event from the user's current location.
public struct TravelEstimate: Sendable, Hashable, Identifiable {
    public let eventID: String
    public let eventStart: Date
    public let travelTime: TimeInterval
    public let transport: TravelTransport

    public init(eventID: String, eventStart: Date, travelTime: TimeInterval, transport: TravelTransport) {
        self.eventID = eventID
        self.eventStart = eventStart
        self.travelTime = travelTime
        self.transport = transport
    }

    public var id: String { eventID }

    public var departureDate: Date {
        eventStart.addingTimeInterval(-travelTime)
    }
}
