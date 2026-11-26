import Foundation

public enum WeatherRefreshSchedule {
    /// A few minutes past midnight, so the new day's forecast has been published.
    public static let delayAfterMidnight: TimeInterval = 5 * 60

    public static func nextRunDate(after now: Date, calendar: Calendar) -> Date {
        let today = calendar.startOfDay(for: now)
        let tonight = calendar.date(byAdding: .day, value: 1, to: today) ?? today.addingTimeInterval(86_400)
        let todaysRun = today.addingTimeInterval(delayAfterMidnight)
        return now < todaysRun ? todaysRun : tonight.addingTimeInterval(delayAfterMidnight)
    }
}
