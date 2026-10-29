import Foundation

public struct RunningCountdown: Sendable, Hashable, Identifiable {
    public let id: String
    public let attributes: EventCountdownAttributes
    public let state: EventCountdownAttributes.ContentState

    public init(id: String, attributes: EventCountdownAttributes, state: EventCountdownAttributes.ContentState) {
        self.id = id
        self.attributes = attributes
        self.state = state
    }

    public func belongs(to event: CalendarEvent) -> Bool {
        attributes.reference.matchScore(against: event.reference) != nil
    }
}
