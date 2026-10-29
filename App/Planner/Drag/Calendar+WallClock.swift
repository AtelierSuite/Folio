import Foundation

extension Calendar {
    /// The day and wall clock hour of `date`. An end date at midnight reads as hour 24 of the
    /// day before, so an event ending at midnight keeps its end on its own day.
    func wallClockPoint(of date: Date, isEnd: Bool = false) -> TimelineDragPoint {
        let dayStart = startOfDay(for: date)
        if isEnd && date == dayStart, let previousDay = self.date(byAdding: .day, value: -1, to: dayStart) {
            return TimelineDragPoint(dayStart: startOfDay(for: previousDay), hour: TimelineDays.hoursPerDay)
        }
        let components = dateComponents([.hour, .minute, .second], from: date)
        let hour = Double(components.hour ?? 0)
            + Double(components.minute ?? 0) / 60
            + Double(components.second ?? 0) / 3600
        return TimelineDragPoint(dayStart: dayStart, hour: hour)
    }

    /// The date at a wall clock hour, counting whole days from `dayStart`. Hours past 24 or
    /// below 0 roll into the next or previous day. A skipped DST hour resolves to the hour after it.
    func date(at point: TimelineDragPoint, addingDays dayOffset: Int = 0) -> Date {
        let extraDays = Int((point.hour / TimelineDays.hoursPerDay).rounded(.down))
        let hour = point.hour - Double(extraDays) * TimelineDays.hoursPerDay
        let noon = date(bySettingHour: 12, minute: 0, second: 0, of: point.dayStart) ?? point.dayStart
        let shiftedNoon = date(byAdding: .day, value: dayOffset + extraDays, to: noon) ?? noon
        let day = startOfDay(for: shiftedNoon)
        let wholeHour = Int(hour.rounded(.down))
        let seconds = ((hour - Double(wholeHour)) * 3600).rounded()
        let wholeHourDate = date(bySettingHour: wholeHour, minute: 0, second: 0, of: day) ?? day
        return wholeHourDate.addingTimeInterval(seconds)
    }

    func dayCount(from start: Date, to end: Date) -> Int {
        dateComponents([.day], from: startOfDay(for: start), to: startOfDay(for: end)).day ?? 0
    }
}
