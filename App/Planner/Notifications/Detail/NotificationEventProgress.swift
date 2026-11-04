import Foundation

/// Where an event stands at a moment in time, worked out when the alert is read
/// because a delivered alert can sit in Notification Center long after it fired.
public struct NotificationEventProgress: Sendable, Equatable {
    static var startingNowText: String {
        String(localized: "Status.StartingNow", table: "Notifications", bundle: #bundle)
    }

    static var endedText: String {
        String(localized: "Status.Ended", table: "Notifications", bundle: #bundle)
    }

    public let start: Date
    public let end: Date

    public init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }

    /// `Locale.current` is wrong in the notification extension, which declares no localizations of its own,
    /// so this follows the language the surrounding status text resolves to.
    static var stringsLocale: Locale {
        Locale(identifier: (#bundle).preferredLocalizations.first ?? "en")
    }

    public func text(at now: Date) -> String {
        text(at: now, locale: Self.stringsLocale)
    }

    func text(at now: Date, locale: Locale) -> String {
        if end > start, now >= end { return Self.endedText }
        let secondsUntilStart = start.timeIntervalSince(now)
        guard abs(secondsUntilStart) >= 60 else { return Self.startingNowText }
        let minutes = (secondsUntilStart / 60).rounded(.up)
        if secondsUntilStart > 0 {
            return relativeText(minutes: minutes, from: now, context: .beginningOfSentence, locale: locale)
        }
        return String(
            format: String(localized: "Status.Started", table: "Notifications", bundle: #bundle),
            relativeText(minutes: minutes, from: now, context: .middleOfSentence, locale: locale)
        )
    }

    private func relativeText(
        minutes: Double,
        from now: Date,
        context: Formatter.Context,
        locale: Locale
    ) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = locale
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .numeric
        formatter.formattingContext = context
        return formatter.localizedString(for: now.addingTimeInterval(minutes * 60), relativeTo: now)
    }
}
