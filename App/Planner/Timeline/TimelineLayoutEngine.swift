import Foundation

public struct TimelineLayoutEngine: Sendable {
    public var days: TimelineDays
    public var floatingSourceTimeZone: TimeZone
    public var minimumEntryDuration: TimeInterval

    public init(
        days: TimelineDays,
        floatingSourceTimeZone: TimeZone = .current,
        minimumEntryDuration: TimeInterval = 15 * 60
    ) {
        self.days = days
        self.floatingSourceTimeZone = floatingSourceTimeZone
        self.minimumEntryDuration = minimumEntryDuration
    }

    public func layout(_ entries: [TimelineEntry]) -> TimelineLayout {
        let resolver = TimelineEntryResolver(calendar: days.calendar, floatingSourceTimeZone: floatingSourceTimeZone)
        var timedEntries: [(entry: TimelineEntry, interval: DateInterval)] = []
        var allDayEntries: [(entry: TimelineEntry, interval: DateInterval)] = []
        for entry in entries {
            let interval = resolver.interval(for: entry)
            if entry.isAllDay {
                allDayEntries.append((entry, interval))
            } else {
                timedEntries.append((entry, interval))
            }
        }
        return TimelineLayout(
            days: days,
            timedPlacements: timedPlacements(for: timedEntries),
            allDayPlacements: allDayPlacements(for: allDayEntries)
        )
    }

    public func currentTimePosition(at date: Date) -> TimelineTimePosition? {
        days.position(of: date)
    }
}
