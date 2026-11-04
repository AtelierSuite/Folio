import Foundation

/// How a reminder stands against its due date, worked out when the alert is read.
public struct NotificationReminderProgress: Sendable, Equatable {
    static var dueNowText: String {
        String(localized: "Status.DueNow", table: "Notifications", bundle: #bundle)
    }

    static var dueTodayText: String {
        String(localized: "Status.DueToday", table: "Notifications", bundle: #bundle)
    }

    public let dueDate: Date
    public let hasDueTime: Bool

    public init(dueDate: Date, hasDueTime: Bool) {
        self.dueDate = dueDate
        self.hasDueTime = hasDueTime
    }

    public func text(at now: Date) -> String {
        text(at: now, locale: NotificationRelativeText.stringsLocale, calendar: .autoupdatingCurrent)
    }

    public func isOverdue(at now: Date) -> Bool {
        isOverdue(at: now, calendar: .autoupdatingCurrent)
    }

    func isOverdue(at now: Date, calendar: Calendar) -> Bool {
        hasDueTime ? dueDate.timeIntervalSince(now) <= -60 : daysUntilDue(from: now, calendar: calendar) < 0
    }

    func text(at now: Date, locale: Locale, calendar: Calendar) -> String {
        hasDueTime ? timedText(at: now, locale: locale) : dayText(at: now, locale: locale, calendar: calendar)
    }

    private func timedText(at now: Date, locale: Locale) -> String {
        let secondsUntilDue = dueDate.timeIntervalSince(now)
        guard abs(secondsUntilDue) >= 60 else { return Self.dueNowText }
        let minutes = (secondsUntilDue / 60).rounded(.towardZero)
        guard secondsUntilDue > 0 else {
            return overdueText(.seconds(Int(-minutes) * 60), allowing: [.days, .hours, .minutes], locale: locale)
        }
        let roundedUp = (secondsUntilDue / 60).rounded(.up)
        return dueText(NotificationRelativeText.minutes(roundedUp, context: .middleOfSentence, locale: locale))
    }

    private func dayText(at now: Date, locale: Locale, calendar: Calendar) -> String {
        let days = daysUntilDue(from: now, calendar: calendar)
        if days == 0 { return Self.dueTodayText }
        guard days > 0 else {
            return overdueText(.seconds(-days * 86_400), allowing: [.days], locale: locale)
        }
        return dueText(NotificationRelativeText.days(days, context: .middleOfSentence, locale: locale))
    }

    private func daysUntilDue(from now: Date, calendar: Calendar) -> Int {
        let today = calendar.startOfDay(for: now)
        return calendar.dateComponents([.day], from: today, to: calendar.startOfDay(for: dueDate)).day ?? 0
    }

    private func dueText(_ relative: String) -> String {
        String(format: String(localized: "Status.Due", table: "Notifications", bundle: #bundle), relative)
    }

    private func overdueText(
        _ duration: Duration,
        allowing units: Set<Duration.UnitsFormatStyle.Unit>,
        locale: Locale
    ) -> String {
        var style = Duration.UnitsFormatStyle(allowedUnits: units, width: .wide, maximumUnitCount: 1)
        style.locale = locale
        return String(
            format: String(localized: "Status.OverdueBy", table: "Notifications", bundle: #bundle),
            duration.formatted(style)
        )
    }
}
