import Foundation

/// A timed event with a location where rain is likely when it starts.
public struct RainHighlight: Sendable, Hashable, Identifiable {
    public let eventID: String
    public let eventStart: Date
    public let eventEnd: Date
    public let placeName: String?
    public let precipitationChance: Double

    public init(eventID: String, eventStart: Date, eventEnd: Date, placeName: String?, precipitationChance: Double) {
        self.eventID = eventID
        self.eventStart = eventStart
        self.eventEnd = eventEnd
        self.placeName = placeName
        self.precipitationChance = precipitationChance
    }

    public var id: String { eventID }
}
