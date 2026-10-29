import Foundation

/// The interval a dragged item would get for a pointer position. Moves keep the item's length
/// and shift it by whole days and wall clock hours, so it keeps its time across DST changes.
public struct TimelineDragOperation: Sendable, Hashable {
    public let kind: TimelineDragKind
    public let original: DateInterval
    public let origin: TimelineDragPoint
    public let calendar: Calendar
    public let snap: TimelineDragSnap

    public init(
        kind: TimelineDragKind,
        original: DateInterval,
        origin: TimelineDragPoint,
        calendar: Calendar,
        snap: TimelineDragSnap = .default
    ) {
        self.kind = kind
        self.original = original
        self.origin = origin
        self.calendar = calendar
        self.snap = snap
    }

    public func interval(at pointer: TimelineDragPoint) -> DateInterval {
        let dayOffset = calendar.dayCount(from: origin.dayStart, to: pointer.dayStart)
        let hourDelta = pointer.hour - origin.hour
        let minimumLength = snap.hours * 3600
        switch kind {
        case .move:
            let start = shifted(calendar.wallClockPoint(of: original.start), by: hourDelta, days: dayOffset, isEnd: false)
            return DateInterval(start: start, duration: original.duration)
        case .resizeStart:
            let start = shifted(calendar.wallClockPoint(of: original.start), by: hourDelta, days: dayOffset, isEnd: false)
            return DateInterval(start: min(start, original.end.addingTimeInterval(-minimumLength)), end: original.end)
        case .resizeEnd:
            let end = shifted(
                calendar.wallClockPoint(of: original.end, isEnd: true), by: hourDelta, days: dayOffset, isEnd: true
            )
            return DateInterval(start: original.start, end: max(end, original.start.addingTimeInterval(minimumLength)))
        case .place(let duration):
            let start = shifted(TimelineDragPoint(dayStart: pointer.dayStart, hour: pointer.hour), by: 0, days: 0, isEnd: false)
            return DateInterval(start: start, duration: duration)
        }
    }

    /// Starts stay inside their day so a vertical drag can't roll an item past midnight;
    /// moving to another day is a horizontal drag. Edges may sit on midnight at the end of the day.
    private func shifted(_ point: TimelineDragPoint, by hourDelta: Double, days dayOffset: Int, isEnd: Bool) -> Date {
        let latestHour = isEnd ? TimelineDays.hoursPerDay : TimelineDays.hoursPerDay - snap.hours
        let hour = min(max(snap.snapped(point.hour + hourDelta), 0), latestHour)
        return calendar.date(at: TimelineDragPoint(dayStart: point.dayStart, hour: hour), addingDays: dayOffset)
    }
}
