import Foundation

public struct WakeUpAlarm: Sendable, Hashable, Identifiable {
    public static let identifierPrefix = "folio.wake."

    public let event: CalendarEvent
    public let fireDate: Date

    public init(event: CalendarEvent, fireDate: Date) {
        self.event = event
        self.fireDate = fireDate
    }

    public var id: String {
        let fireSeconds = Int(fireDate.timeIntervalSince1970.rounded(.down))
        return "\(Self.identifierPrefix)\(event.reference.storageKey)@\(fireSeconds)"
    }
}
