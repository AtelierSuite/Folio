import Foundation

public struct TimelineEntry: Sendable, Hashable, Identifiable {
    public let id: String
    public var title: String
    public var start: Date
    public var end: Date
    public var isAllDay: Bool
    /// `nil` makes the entry floating: its wall clock time (read in the engine's
    /// `floatingSourceTimeZone`) is kept in whatever time zone the timeline shows.
    public var timeZone: TimeZone?
    public var color: TimelineColor
    public var isReadOnly: Bool
    public var kind: TimelineEntryKind
    public var location: String?
    public var hasLink: Bool

    public init(
        id: String,
        title: String,
        start: Date,
        end: Date,
        isAllDay: Bool = false,
        timeZone: TimeZone?,
        color: TimelineColor,
        isReadOnly: Bool = false,
        kind: TimelineEntryKind = .event,
        location: String? = nil,
        hasLink: Bool = false
    ) {
        self.id = id
        self.title = title
        self.start = start
        self.end = end
        self.isAllDay = isAllDay
        self.timeZone = timeZone
        self.color = color
        self.isReadOnly = isReadOnly
        self.kind = kind
        self.location = location
        self.hasLink = hasLink
    }

    public var isFloating: Bool {
        timeZone == nil
    }
}
