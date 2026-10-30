import Foundation

public struct LeaveAlert: Sendable, Hashable, Identifiable {
    public static let identifierPrefix = "folio.leave."

    public let event: CalendarEvent
    public let destination: PlannerCoordinate
    public let travelTime: TimeInterval
    public let transport: TravelTransport
    public let leaveDate: Date
    public let fireDate: Date

    public init(
        event: CalendarEvent,
        destination: PlannerCoordinate,
        travelTime: TimeInterval,
        transport: TravelTransport,
        leaveDate: Date,
        fireDate: Date
    ) {
        self.event = event
        self.destination = destination
        self.travelTime = travelTime
        self.transport = transport
        self.leaveDate = leaveDate
        self.fireDate = fireDate
    }

    public var id: String {
        let fireSeconds = Int(fireDate.timeIntervalSince1970.rounded(.down))
        return "\(Self.identifierPrefix)\(event.reference.storageKey)@\(fireSeconds)"
    }

    public var isLate: Bool {
        fireDate >= leaveDate
    }
}
