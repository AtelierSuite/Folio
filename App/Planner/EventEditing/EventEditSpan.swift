import Foundation

public enum EventEditSpan: Sendable, Hashable, CaseIterable {
    case thisEvent
    case futureEvents
    /// EventKit has no span for the whole series, so this edits the first occurrence with `futureEvents`.
    case allEvents
}
