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

    public func text(at now: Date) -> String {
        text(at: now, locale: NotificationRelativeText.stringsLocale)
    }

    func text(at now: Date, locale: Locale) -> String {
        if end > start, now >= end { return Self.endedText }
        let secondsUntilStart = start.timeIntervalSince(now)
        guard abs(secondsUntilStart) >= 60 else { return Self.startingNowText }
        let minutes = (secondsUntilStart / 60).rounded(.up)
        if secondsUntilStart > 0 {
            return NotificationRelativeText.minutes(minutes, context: .beginningOfSentence, locale: locale)
        }
        return String(
            format: String(localized: "Status.Started", table: "Notifications", bundle: #bundle),
            NotificationRelativeText.minutes(minutes, context: .middleOfSentence, locale: locale)
        )
    }
}
