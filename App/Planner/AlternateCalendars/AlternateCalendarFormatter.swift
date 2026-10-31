import Foundation

public struct AlternateCalendarFormatter: Equatable, Sendable {
    public let alternateCalendar: AlternateCalendar
    public let calendar: Calendar
    public let locale: Locale

    public init(alternateCalendar: AlternateCalendar, timeZone: TimeZone, locale: Locale) {
        var calendar = Calendar(identifier: alternateCalendar.identifier)
        calendar.timeZone = timeZone
        calendar.locale = locale
        self.alternateCalendar = alternateCalendar
        self.calendar = calendar
        self.locale = locale
    }

    public func dayLabel(for date: Date) -> String? {
        guard !alternateCalendar.sharesGregorianDays else { return nil }
        if calendar.component(.day, from: date) == 1 {
            return monthStartLabel(for: date)
        }
        if usesChineseNumerals {
            return date.formatted(formatStyle.day())
        }
        let format = Date.VerbatimFormatStyle(
            format: "\(day: .defaultDigits)",
            locale: locale,
            timeZone: calendar.timeZone,
            calendar: calendar
        )
        return date.formatted(format)
    }

    public func fullDate(for date: Date) -> String {
        date.formatted(formatStyle.year().era().month(.wide).day())
    }

    public func monthTitle(for interval: DateInterval) -> String {
        let lastMoment = max(interval.start, interval.end.addingTimeInterval(-1))
        let style = Date.IntervalFormatStyle(locale: locale, calendar: calendar, timeZone: calendar.timeZone)
            .month(.wide)
            .year()
        return (interval.start..<lastMoment).formatted(style)
    }

    private var formatStyle: Date.FormatStyle {
        Date.FormatStyle(locale: locale, calendar: calendar, timeZone: calendar.timeZone)
    }

    private var languageCode: String? {
        locale.language.languageCode?.identifier
    }

    private var usesChineseNumerals: Bool {
        alternateCalendar.isChineseLunisolar && languageCode == "zh"
    }

    private var usesMonthNames: Bool {
        guard alternateCalendar.isChineseLunisolar else { return true }
        return ["zh", "ja", "ko", "vi"].contains(languageCode ?? "")
    }

    private func monthStartLabel(for date: Date) -> String {
        if usesMonthNames {
            return date.formatted(formatStyle.month(.abbreviated))
        }
        return date.formatted(formatStyle.month(.defaultDigits).day())
    }
}
