import Foundation

extension TimelineDays {
    /// The start of the snapped slot a tap at `hour` falls in, such as 10:30 for a tap at 10:40.
    public func startOfSlot(onDay dayIndex: Int, atHour hour: Double, snap: TimelineDragSnap) -> Date? {
        let slotHour = (hour / snap.hours).rounded(.down) * snap.hours
        let clampedHour = min(max(slotHour, 0), Self.hoursPerDay - snap.hours)
        return TimelineDragPoint(dayIndex: dayIndex, hour: clampedHour, in: self).map { calendar.date(at: $0) }
    }
}
