import Foundation

public struct NotificationContentFormatter: Sendable {
    static let separator = " · "

    public var calendar: Calendar
    public var locale: Locale

    public init(calendar: Calendar = .autoupdatingCurrent, locale: Locale = .autoupdatingCurrent) {
        self.calendar = calendar
        self.locale = locale
    }

    public func content(for event: CalendarEvent, firingAt fireDate: Date) -> NotificationContent {
        let location = event.location?.trimmingCharacters(in: .whitespacesAndNewlines)
        return NotificationContent(
            title: event.title,
            body: joined([eventTime(for: event, firingAt: fireDate), location])
        )
    }

    public func content(for reminder: ReminderItem, firingAt fireDate: Date) -> NotificationContent {
        NotificationContent(title: reminder.title, body: reminderTime(for: reminder, firingAt: fireDate) ?? "")
    }

    private func eventTime(for event: CalendarEvent, firingAt fireDate: Date) -> String {
        let isSameDay = calendar.isDate(event.startDate, inSameDayAs: fireDate)
        if event.isAllDay {
            let allDay = String(localized: "AllDay", table: "Notifications", bundle: #bundle, locale: locale)
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
