import Foundation

/// Moving an item to another date, as in month view: timed items keep their wall clock time
/// and length, all-day items keep their number of days.
public enum CalendarDayMove {
    public static func interval(
        _ interval: DateInterval,
        isAllDay: Bool,
        from fromDay: Date,
        to toDay: Date,
        calendar: Calendar
    ) -> DateInterval {
        let dayOffset = calendar.dayCount(from: fromDay, to: toDay)
        guard isAllDay else {
            let start = calendar.date(at: calendar.wallClockPoint(of: interval.start), addingDays: dayOffset)
            return DateInterval(start: start, duration: interval.duration)
        }
        let start = calendar.date(at: TimelineDragPoint(dayStart: calendar.startOfDay(for: interval.start), hour: 0),
                                  addingDays: dayOffset)
        let end = calendar.date(at: calendar.wallClockPoint(of: interval.end), addingDays: dayOffset)
        return DateInterval(start: start, end: max(start, end))
    }

    public static func date(_ date: Date, from fromDay: Date, to toDay: Date, calendar: Calendar) -> Date {
        let dayOffset = calendar.dayCount(from: fromDay, to: toDay)
        return calendar.date(at: calendar.wallClockPoint(of: date), addingDays: dayOffset)
    }
}
