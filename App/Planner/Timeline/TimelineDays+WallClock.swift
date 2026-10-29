import Foundation

extension TimelineDays {
    public static let hoursPerDay = 24.0

    /// Hours are wall clock hours, so every day has 24 rows: on a 23 hour day the skipped
    /// hour is empty and on a 25 hour day the repeated hour is drawn once.
    public func hour(of date: Date, onDay dayIndex: Int) -> Double {
        let day = intervals[dayIndex]
        guard date > day.start else { return 0 }
        guard date < day.end else { return Self.hoursPerDay }
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
        let hour = Double(components.hour ?? 0)
        let minute = Double(components.minute ?? 0)
        let second = Double(components.second ?? 0)
        return hour + minute / 60 + second / 3600
    }

    public func segments(from start: Date, to end: Date) -> [TimelineDaySegment] {
        let end = max(start, end)
        return intervals.indices.compactMap { dayIndex in
            let day = intervals[dayIndex]
            let isInstant = start == end
            let touchesDay = isInstant ? day.start <= start && start < day.end : start < day.end && end > day.start
            guard touchesDay else { return nil }
            let clippedStart = max(start, day.start)
            let clippedEnd = min(end, day.end)
            let startHour = hour(of: clippedStart, onDay: dayIndex)
            var endHour = hour(of: clippedEnd, onDay: dayIndex)
            if endHour < startHour {
                let elapsedHours = clippedEnd.timeIntervalSince(clippedStart) / 3600
                endHour = min(Self.hoursPerDay, startHour + elapsedHours)
            }
            return TimelineDaySegment(
                dayIndex: dayIndex,
                startHour: startHour,
                endHour: endHour,
                continuesFromPreviousDay: start < day.start,
                continuesToNextDay: end > day.end
            )
        }
    }

    public func date(atHour hour: Double, onDay dayIndex: Int) -> Date {
        let day = intervals[dayIndex]
        let wholeHour = Int(hour.rounded(.down))
        let seconds = (hour - Double(wholeHour)) * 3600
        guard wholeHour < Int(Self.hoursPerDay),
              let date = calendar.date(bySettingHour: wholeHour, minute: 0, second: 0, of: day.start) else {
            return day.end
        }
        return date.addingTimeInterval(seconds)
    }
}
