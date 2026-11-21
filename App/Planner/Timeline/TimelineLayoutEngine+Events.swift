import Foundation

public struct TimelineContents: Sendable, Equatable {
    public let entries: [TimelineEntry]
    public let layout: TimelineLayout
}

extension TimelineLayoutEngine {
    /// Merges duplicate events into one entry each and lays them out with `otherEntries`, off the main actor.
    @concurrent
    public func contents(events: [CalendarEvent], otherEntries: [TimelineEntry]) async -> TimelineContents {
        let eventEntries = EventDuplicateDetector(calendar: days.calendar).groups(in: events)
            .map(TimelineEntry.init(group:))
        let entries = eventEntries + otherEntries
        return TimelineContents(entries: entries, layout: layout(entries))
    }
}
