import Foundation

public struct MonthDayBuckets: Sendable, Equatable {
    public static let empty = MonthDayBuckets(itemsByDay: [:])

    private let itemsByDay: [Date: [MonthDayItem]]

    init(itemsByDay: [Date: [MonthDayItem]]) {
        self.itemsByDay = itemsByDay
    }

    public init(grid: MonthGrid, entries: [TimelineEntry], floatingSourceTimeZone: TimeZone? = nil) {
        let resolver = TimelineEntryResolver(
            calendar: grid.calendar, floatingSourceTimeZone: floatingSourceTimeZone ?? grid.calendar.timeZone
        )
        var itemsByDay: [Date: [MonthDayItem]] = [:]
        for entry in entries {
            let interval = resolver.interval(for: entry)
            for day in grid.days where Self.interval(interval, touches: day.interval) {
                itemsByDay[day.date, default: []].append(MonthDayItem(
                    entry: entry,
                    continuesFromPreviousDay: interval.start < day.interval.start,
                    continuesToNextDay: interval.end > day.interval.end
                ))
            }
        }
        self.itemsByDay = itemsByDay.mapValues { $0.sorted(by: Self.displayOrder) }
    }

    public func items(on day: MonthDay) -> [MonthDayItem] {
        itemsByDay[day.date] ?? []
    }

    static func interval(_ interval: DateInterval, touches day: DateInterval) -> Bool {
        if interval.duration == 0 {
            return day.start <= interval.start && interval.start < day.end
        }
        return interval.start < day.end && interval.end > day.start
    }
}
