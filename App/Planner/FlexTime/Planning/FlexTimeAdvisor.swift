import Foundation

/// Decides whether a day's events need delaying and where the first one should start.
public struct FlexTimeAdvisor: Sendable {
    public var calendar: Calendar
    /// How long after waking up the first event can start.
    public var readyTime: TimeInterval
    public var roundingInterval: TimeInterval
    /// Shorter sleep is a nap, which says nothing about when the day started.
    public var minimumSleepDuration: TimeInterval

    public init(
        calendar: Calendar = .current,
        readyTime: TimeInterval = 30 * 60,
        roundingInterval: TimeInterval = 15 * 60,
        minimumSleepDuration: TimeInterval = 2 * 3600
    ) {
        self.calendar = calendar
        self.readyTime = readyTime
        self.roundingInterval = roundingInterval
        self.minimumSleepDuration = minimumSleepDuration
    }

    public func dayInterval(containing date: Date) -> DateInterval {
        let start = calendar.startOfDay(for: date)
        return DateInterval(start: start, end: calendar.date(byAdding: .day, value: 1, to: start) ?? start)
    }

    public func timedEvents(on date: Date, among events: [CalendarEvent]) -> [CalendarEvent] {
        let day = dayInterval(containing: date)
        return events
            .map(\.withoutFlexTime)
            .filter { !$0.isAllDay && day.start <= $0.startDate && $0.startDate < day.end }
            .sorted { ($0.startDate, $0.id) < ($1.startDate, $1.id) }
    }

    public func wakeTime(from sessions: [SleepSession], on date: Date) -> Date? {
        let day = dayInterval(containing: date)
        return sessions
            .filter { day.contains($0.interval.end) && $0.interval.duration >= minimumSleepDuration }
            .max { $0.interval.duration < $1.interval.duration }?
            .interval.end
    }

    public func isNeeded(firstEventStart: Date, wakeTime: Date) -> Bool {
        wakeTime.addingTimeInterval(readyTime) > firstEventStart
    }

    public func suggestedStart(firstEventStart: Date, wakeTime: Date?, now: Date) -> Date {
        let day = dayInterval(containing: firstEventStart)
        let ready = wakeTime.map { $0.addingTimeInterval(readyTime) } ?? now
        let earliest = max(ready, now, firstEventStart)
        let elapsed = earliest.timeIntervalSince(day.start)
        let rounded = day.start.addingTimeInterval((elapsed / roundingInterval).rounded(.up) * roundingInterval)
        return min(rounded, latestStart(on: day))
    }

    /// With `requiresNeed`, only a day whose first event starts before the user could be ready gets a proposal.
    public func proposal(
        events: [CalendarEvent],
        wake: FlexTimeWake?,
        now: Date,
        activeDelay: TimeInterval = 0,
        activeExcludedCalendars: Set<String> = [],
        requiresNeed: Bool
    ) -> FlexTimeProposal? {
        let day = dayInterval(containing: now)
        let timedEvents = timedEvents(on: now, among: events)
        guard let firstEvent = timedEvents.first else { return nil }
        let todaysWake = wake.flatMap { day.contains($0.time) && $0.time <= now ? $0 : nil }
        if requiresNeed {
            guard let todaysWake, isNeeded(firstEventStart: firstEvent.startDate, wakeTime: todaysWake.time) else {
                return nil
            }
        }
        let firstDelayedEvent = timedEvents.first { !activeExcludedCalendars.contains($0.calendarIdentifier) }
        let suggestedStart = activeDelay > 0
            ? min((firstDelayedEvent ?? firstEvent).startDate.addingTimeInterval(activeDelay), latestStart(on: day))
            : suggestedStart(firstEventStart: firstEvent.startDate, wakeTime: todaysWake?.time, now: now)
        if requiresNeed && suggestedStart <= firstEvent.startDate {
            return nil
        }
        return FlexTimeProposal(
            day: day.start,
            events: timedEvents,
            wake: todaysWake,
            suggestedStart: suggestedStart,
            latestStart: latestStart(on: day),
            activeDelay: activeDelay,
            activeExcludedCalendars: activeDelay > 0 ? activeExcludedCalendars : []
        )
    }

    private func latestStart(on day: DateInterval) -> Date {
        day.end.addingTimeInterval(-roundingInterval)
    }
}
