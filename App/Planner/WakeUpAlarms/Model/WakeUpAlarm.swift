import Foundation

public struct WakeUpAlarm: Sendable, Hashable, Identifiable {
    public static let identifierPrefix = "folio.wake."

    public let event: CalendarEvent
    public let fireDate: Date
    public let travelTime: TimeInterval?

    public init(event: CalendarEvent, fireDate: Date, travelTime: TimeInterval? = nil) {
        self.event = event
        self.fireDate = fireDate
        self.travelTime = travelTime
    }

    public var id: String {
        let fireSeconds = Int(fireDate.timeIntervalSince1970.rounded(.down))
        return "\(Self.identifierPrefix)\(event.reference.storageKey)@\(fireSeconds)"
    }
}
