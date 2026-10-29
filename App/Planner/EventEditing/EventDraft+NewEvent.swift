import Foundation

extension EventDraft {
    public static let defaultDuration: TimeInterval = 3600

    public static func newEvent(
        on day: Date,
        calendarIdentifier: String,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> EventDraft {
        let startDate = defaultStartDate(on: day, now: now, calendar: calendar)
        return EventDraft(
            calendarIdentifier: calendarIdentifier,
            startDate: startDate,
            endDate: startDate.addingTimeInterval(defaultDuration),
            timeZone: calendar.timeZone
        )
    }

    static func defaultStartDate(on day: Date, now: Date, calendar: Calendar) -> Date {
        let startOfDay = calendar.startOfDay(for: day)
        guard calendar.isDate(day, inSameDayAs: now),
              let currentHour = calendar.dateInterval(of: .hour, for: now),
              let nextHour = calendar.date(byAdding: .hour, value: 1, to: currentHour.start),
              calendar.isDate(nextHour, inSameDayAs: now) else {
            return calendar.date(bySettingHour: 9, minute: 0, second: 0, of: startOfDay) ?? startOfDay
        }
        return nextHour
    }

    public mutating func setAllDay(_ isAllDay: Bool, calendar: Calendar = .current) {
        guard isAllDay != self.isAllDay else { return }
        self.isAllDay = isAllDay
        if isAllDay {
            startDate = calendar.startOfDay(for: startDate)
            let lastDay = calendar.startOfDay(for: max(endDate.addingTimeInterval(-1), startDate))
            endDate = calendar.date(byAdding: .day, value: 1, to: lastDay) ?? startDate
            timeZone = nil
        } else {
            startDate = Self.defaultStartDate(on: startDate, now: .now, calendar: calendar)
            endDate = startDate.addingTimeInterval(Self.defaultDuration)
            timeZone = calendar.timeZone
        }
        alerts = alerts.isEmpty ? [] : [EventAlert.defaultAlert(isAllDay: isAllDay)]
    }

    public mutating func moveStart(to newStart: Date) {
        let currentDuration = max(duration, 0)
        startDate = newStart
        endDate = newStart.addingTimeInterval(currentDuration)
    }
}
