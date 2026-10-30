import Foundation

extension NotificationScheduler {
    public func allDayAlertMinutes(forCalendar calendarIdentifier: String) -> Int {
        allDayAlertTimeSettings.minutesAfterMidnight(forCalendar: calendarIdentifier)
    }

    public func setAllDayAlertMinutes(_ minutes: Int, forCalendar calendarIdentifier: String) async {
        allDayAlertTimeSettings.setMinutesAfterMidnight(minutes, forCalendar: calendarIdentifier)
        await replan()
    }
}
