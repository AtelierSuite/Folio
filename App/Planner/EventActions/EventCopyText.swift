import Foundation

/// The plain text Copy puts on the pasteboard: title, date and time, place, meeting link and URL.
public enum EventCopyText {
    public static func text(
        for event: CalendarEvent,
        calendar: Calendar = .current,
        locale: Locale = .current
    ) -> String {
        var lines = [event.title, dateDescription(for: event, calendar: calendar, locale: locale)]
        if let location = event.location?.trimmingCharacters(in: .whitespacesAndNewlines), !location.isEmpty {
            lines.append(location)
        }
        let links = [event.meetingLink?.url, event.url].compactMap(\.self)
        for link in links where !lines.contains(link.absoluteString) {
            lines.append(link.absoluteString)
        }
        return lines.joined(separator: "\n")
    }

    static func dateDescription(for event: CalendarEvent, calendar: Calendar, locale: Locale) -> String {
        let timeZone = event.isAllDay ? calendar.timeZone : (event.timeZone ?? calendar.timeZone)
        let dateStyle = Date.FormatStyle(
            date: .complete, time: .omitted, locale: locale, calendar: calendar, timeZone: timeZone
        )
        guard !event.isAllDay else {
            let lastDay = max(event.startDate, event.endDate.addingTimeInterval(-1))
            guard !calendar.isDate(lastDay, inSameDayAs: event.startDate) else {
                return event.startDate.formatted(dateStyle)
            }
            return "\(event.startDate.formatted(dateStyle)) – \(lastDay.formatted(dateStyle))"
        }
        let intervalStyle = Date.IntervalFormatStyle(
            date: .complete, time: .shortened, locale: locale, calendar: calendar, timeZone: timeZone
        )
        return (event.startDate..<max(event.startDate, event.endDate)).formatted(intervalStyle)
    }
}
