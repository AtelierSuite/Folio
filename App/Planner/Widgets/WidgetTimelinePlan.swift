import Foundation

/// When a widget's entries change: now, each event's start and end, and midnight, so the
/// widget stays current without spending refresh budget.
public struct WidgetTimelinePlan: Sendable, Equatable {
    public static let defaultRefreshInterval: TimeInterval = 6 * 60 * 60
    /// Changes made outside Folio can't reach a widget, so Lock Screen counts are re-read this often.
    public static let lockScreenRefreshInterval: TimeInterval = 60 * 60
    public static let defaultEntryLimit = 40

    public let entryDates: [Date]
    public let reloadDate: Date

    public init(
        events: [CalendarEvent],
        from now: Date,
        calendar: Calendar,
        refreshInterval: TimeInterval = Self.defaultRefreshInterval,
        entryLimit: Int = Self.defaultEntryLimit,
        tickInterval: TimeInterval? = nil
    ) {
        let startOfToday = calendar.startOfDay(for: now)
        let nextMidnight = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? now.addingTimeInterval(86_400)
        let horizon = min(nextMidnight, now.addingTimeInterval(refreshInterval))
        let boundaries = events
            .filter { !$0.isAllDay }
            .flatMap { [$0.startDate, $0.endDate] }
            .filter { now < $0 && $0 < horizon }
        let ticks = tickInterval.map { Self.ticks(every: $0, after: now, before: horizon, calendar: calendar) } ?? []
        let dates = Array(Set(boundaries + ticks + [horizon])).sorted()
        let limitedDates = Array(dates.prefix(max(entryLimit - 1, 1)))
        entryDates = [now] + limitedDates
        reloadDate = limitedDates.last ?? horizon
    }

    private static func ticks(
        every interval: TimeInterval,
        after now: Date,
        before horizon: Date,
        calendar: Calendar
    ) -> [Date] {
        guard interval > 0 else { return [] }
        let hourStart = calendar.dateInterval(of: .hour, for: now)?.start ?? now
        let elapsedTicks = (now.timeIntervalSince(hourStart) / interval).rounded(.down)
        let firstTick = hourStart.addingTimeInterval((elapsedTicks + 1) * interval)
        return Array(stride(from: firstTick, to: horizon, by: interval))
    }
}
