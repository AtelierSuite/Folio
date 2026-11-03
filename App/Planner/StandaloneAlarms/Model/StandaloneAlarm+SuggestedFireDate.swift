import Foundation

extension StandaloneAlarm {
    /// The tapped time, or 7:00 for a whole day, moved to the next whole hour when that has already passed.
    public static func suggestedFireDate(at date: Date, hasTime: Bool, now: Date, calendar: Calendar) -> Date {
        let suggestion = hasTime ? date : calendar.date(bySettingHour: 7, minute: 0, second: 0, of: date) ?? date
        guard suggestion <= now else { return suggestion }
        return calendar.dateInterval(of: .hour, for: now)?.end ?? now.addingTimeInterval(3600)
    }
}
