import Foundation

extension NotificationContentFormatter {
    /// The time shown in the expanded alert, or `nil` when the event has no span to describe.
    func detailedTime(for event: CalendarEvent, firingAt fireDate: Date) -> String? {
        event.isAllDay ? allDaySpan(of: event) : timedSpan(of: event, firingAt: fireDate)
    }

    private func timedSpan(of event: CalendarEvent, firingAt fireDate: Date) -> String? {
        guard event.endDate > event.startDate else { return nil }
        let startsOnFireDay = calendar.isDate(event.startDate, inSameDayAs: fireDate)
        let endsOnStartDay = calendar.isDate(event.endDate, inSameDayAs: event.startDate)
        return spanText(
            start: startsOnFireDay ? event.startDate.formatted(timeStyle) : dayAndTimeText(event.startDate),
            end: endsOnStartDay ? event.endDate.formatted(timeStyle) : dayAndTimeText(event.endDate),
            duration: durationText(from: event.startDate, to: event.endDate)
        )
    }

    private func allDaySpan(of event: CalendarEvent) -> String? {
        // All-day events can end at midnight of the following day.
        let firstDay = calendar.startOfDay(for: event.startDate)
        let lastDay = calendar.startOfDay(for: max(event.startDate, event.endDate.addingTimeInterval(-1)))
        let dayCount = (calendar.dateComponents([.day], from: firstDay, to: lastDay).day ?? 0) + 1
        guard dayCount > 1 else { return nil }
        return spanText(
            start: firstDay.formatted(dayStyle),
            end: lastDay.formatted(dayStyle),
            duration: unitsText(.seconds(dayCount * 86_400), allowing: [.days])
        )
    }

    private func spanText(start: String, end: String, duration: String) -> String {
        String(
            format: String(localized: "TimeSpanWithDuration", table: "Notifications", bundle: #bundle),
            start, end, duration
        )
    }

    private func durationText(from start: Date, to end: Date) -> String {
        let minutes = max(1, Int((end.timeIntervalSince(start) / 60).rounded()))
        return unitsText(.seconds(minutes * 60), allowing: [.days, .hours, .minutes])
            .replacingOccurrences(of: ", ", with: " ")
    }

    private func unitsText(_ duration: Duration, allowing units: Set<Duration.UnitsFormatStyle.Unit>) -> String {
        var style = Duration.UnitsFormatStyle(allowedUnits: units, width: .wide)
        style.locale = locale
        return duration.formatted(style)
    }

    private func dayAndTimeText(_ date: Date) -> String {
        "\(date.formatted(dayStyle)) \(date.formatted(timeStyle))"
    }

    private var timeStyle: Date.FormatStyle {
        Date.FormatStyle(
            date: .omitted, time: .shortened, locale: locale, calendar: calendar, timeZone: calendar.timeZone
        )
    }

    private var dayStyle: Date.FormatStyle {
        Date.FormatStyle(locale: locale, calendar: calendar, timeZone: calendar.timeZone).month(.abbreviated).day()
    }
}
