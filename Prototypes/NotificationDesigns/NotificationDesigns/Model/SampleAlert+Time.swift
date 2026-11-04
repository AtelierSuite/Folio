import Foundation

extension SampleAlert {
    struct TimeSpan {
        let start: String
        let end: String
        let duration: String
    }

    var timeSpan: TimeSpan? {
        switch schedule {
        case let .timed(start, end):
            let isSameDay = Calendar.current.isDate(start, inSameDayAs: end)
            return TimeSpan(
                start: timeText(start),
                end: isSameDay ? timeText(end) : dayAndTimeText(end),
                duration: durationText(from: start, to: end)
            )
        case let .allDay(start, end):
            guard !Calendar.current.isDate(start, inSameDayAs: end) else { return nil }
            return TimeSpan(start: dayText(start), end: dayText(end), duration: dayCountText(from: start, to: end))
        case .due:
            return nil
        }
    }

    var rangeText: String {
        if let timeSpan { return "\(timeSpan.start) ~ \(timeSpan.end)" }
        return singleMomentText
    }

    var timeSummary: String {
        if let timeSpan { return "\(timeSpan.start) ~ \(timeSpan.end) (\(timeSpan.duration))" }
        return singleMomentText
    }

    var dayNumber: String { startDate.formatted(.dateTime.day().locale(locale)) }
    var monthName: String { startDate.formatted(.dateTime.month(.abbreviated).locale(locale)) }

    private var startDate: Date {
        switch schedule {
        case let .timed(start, _), let .allDay(start, _): start
        case let .due(date): date
        }
    }

    private var singleMomentText: String {
        switch schedule {
        case .timed, .allDay: "All day"
        case let .due(date): "Due \(timeText(date))"
        }
    }

    private func timeText(_ date: Date) -> String {
        date.formatted(.dateTime.hour().minute().locale(locale))
    }

    private func dayText(_ date: Date) -> String {
        date.formatted(.dateTime.month(.abbreviated).day().locale(locale))
            .replacingOccurrences(of: " ", with: "\u{00A0}")
    }

    private func dayAndTimeText(_ date: Date) -> String {
        "\(dayText(date)), \(timeText(date))"
    }

    private func durationText(from start: Date, to end: Date) -> String {
        var calendar = Calendar.current
        calendar.locale = locale
        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        return (formatter.string(from: start, to: end) ?? "").replacingOccurrences(of: ", ", with: " ")
    }

    private func dayCountText(from start: Date, to end: Date) -> String {
        var calendar = Calendar.current
        calendar.locale = locale
        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.allowedUnits = [.day]
        formatter.unitsStyle = .full
        let inclusiveEnd = calendar.date(byAdding: .day, value: 1, to: end) ?? end
        return formatter.string(from: start, to: inclusiveEnd) ?? ""
    }
}
