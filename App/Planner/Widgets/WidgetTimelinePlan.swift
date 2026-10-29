import Foundation

/// When a widget's entries change: now, each event's start and end, and midnight, so the
/// widget stays current without spending refresh budget.
public struct WidgetTimelinePlan: Sendable, Equatable {
    public static let defaultRefreshInterval: TimeInterval = 6 * 60 * 60
    public static let defaultEntryLimit = 40

    public let entryDates: [Date]
    public let reloadDate: Date

    public init(
        events: [CalendarEvent],
        from now: Date,
        calendar: Calendar,
        refreshInterval: TimeInterval = Self.defaultRefreshInterval,
        entryLimit: Int = Self.defaultEntryLimit
    ) {
        let startOfToday = calendar.startOfDay(for: now)
        let nextMidnight = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? now.addingTimeInterval(86_400)
        let horizon = min(nextMidnight, now.addingTimeInterval(refreshInterval))
        let boundaries = events
            .filter { !$0.isAllDay }
            .flatMap { [$0.startDate, $0.endDate] }
            .filter { now < $0 && $0 < horizon }
        let dates = Array(Set(boundaries + [horizon])).sorted()
        let limitedDates = Array(dates.prefix(max(entryLimit - 1, 1)))
        entryDates = [now] + limitedDates
        reloadDate = limitedDates.last ?? horizon
    }
}
