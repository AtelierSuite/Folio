import Foundation

public struct NotificationContentFormatter: Sendable {
    static let separator = " · "

    static var allDayText: String {
        String(localized: "AllDay", table: "Notifications", bundle: #bundle)
    }

    public var calendar: Calendar
    public var locale: Locale

    public init(calendar: Calendar = .autoupdatingCurrent, locale: Locale = .autoupdatingCurrent) {
        self.calendar = calendar
        self.locale = locale
    }

    public func content(for event: CalendarEvent, firingAt fireDate: Date) -> NotificationContent {
        let location = event.location?.trimmingCharacters(in: .whitespacesAndNewlines)
        let time = eventTime(for: event, firingAt: fireDate)
        let startTime = event.isAllDay ? nil : self.time(of: event.startDate, firingAt: fireDate)
        return NotificationContent(
            title: event.title,
            body: joined([time, location]),
            alarmTitle: joined([event.title, startTime]),
            time: detailedTime(for: event, firingAt: fireDate) ?? time,
            color: event.color,
            origin: event.origin
        )
    }

    public func content(for reminder: ReminderItem, firingAt fireDate: Date) -> NotificationContent {
        let time = reminderTime(for: reminder, firingAt: fireDate)
        let dueTime = reminder.hasDueTime ? reminder.dueDate.map { self.time(of: $0, firingAt: fireDate) } : nil
        return NotificationContent(
            title: reminder.title,
            body: time ?? "",
            alarmTitle: joined([reminder.title, dueTime]),
            time: time,
            color: reminder.color,
            origin: reminder.origin
        )
    }

    func time(of date: Date, firingAt fireDate: Date) -> String {
        let isSameDay = calendar.isDate(date, inSameDayAs: fireDate)
        return date.formatted(dateStyle(date: isSameDay ? .omitted : .abbreviated, time: .shortened))
    }

    private func eventTime(for event: CalendarEvent, firingAt fireDate: Date) -> String {
        let isSameDay = calendar.isDate(event.startDate, inSameDayAs: fireDate)
        if event.isAllDay {
            let allDay = Self.allDayText
            return isSameDay ? allDay : joined([event.startDate.formatted(dateStyle(date: .abbreviated)), allDay])
        }
        let date: Date.IntervalFormatStyle.DateStyle? = isSameDay ? nil : .abbreviated
        guard event.endDate > event.startDate else {
            return event.startDate.formatted(dateStyle(date: isSameDay ? .omitted : .abbreviated, time: .shortened))
        }
        let style = Date.IntervalFormatStyle(
            date: date, time: .shortened, locale: locale, calendar: calendar, timeZone: calendar.timeZone
        )
        return (event.startDate..<event.endDate).formatted(style)
    }

    private func reminderTime(for reminder: ReminderItem, firingAt fireDate: Date) -> String? {
        guard let dueDate = reminder.dueDate else { return nil }
        let isSameDay = calendar.isDate(dueDate, inSameDayAs: fireDate)
        if reminder.hasDueTime {
            return dueDate.formatted(dateStyle(date: isSameDay ? .omitted : .abbreviated, time: .shortened))
        }
        return dueDate.formatted(dateStyle(date: .abbreviated))
    }

    private func dateStyle(
        date: Date.FormatStyle.DateStyle,
        time: Date.FormatStyle.TimeStyle = .omitted
    ) -> Date.FormatStyle {
        Date.FormatStyle(date: date, time: time, locale: locale, calendar: calendar, timeZone: calendar.timeZone)
    }

    private func joined(_ parts: [String?]) -> String {
        parts.compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: Self.separator)
    }
}
