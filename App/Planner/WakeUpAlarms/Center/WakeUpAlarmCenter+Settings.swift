import Foundation

extension WakeUpAlarmCenter {
    public func setEnabled(_ isEnabled: Bool) async {
        guard isSupported else { return }
        self.isEnabled = isEnabled
        settings.isEnabled = isEnabled
        if isEnabled, await alarmClient.authorization() == .notDetermined {
            _ = try? await alarmClient.requestAuthorization()
        }
        await replan()
    }

    public func setLeadMinutes(_ minutes: Int) async {
        leadMinutes = minutes
        settings.leadMinutes = minutes
        await replan()
    }

    public func setEarliestMinutes(_ minutes: Int) async {
        earliestMinutes = minutes
        settings.earliestMinutes = minutes
        await replan()
    }

    public func setLatestEventMinutes(_ minutes: Int) async {
        latestEventMinutes = minutes
        settings.latestEventMinutes = minutes
        await replan()
    }

    public func setSkipsHolidays(_ skipsHolidays: Bool) async {
        self.skipsHolidays = skipsHolidays
        settings.skipsHolidays = skipsHolidays
        await replan()
    }

    public func includesCalendar(_ calendarIdentifier: String) -> Bool {
        !excludedCalendarIdentifiers.contains(calendarIdentifier)
    }

    public func setIncludesCalendar(_ isIncluded: Bool, calendarIdentifier: String) async {
        if isIncluded {
            excludedCalendarIdentifiers.remove(calendarIdentifier)
        } else {
            excludedCalendarIdentifiers.insert(calendarIdentifier)
        }
        settings.excludedCalendarIdentifiers = excludedCalendarIdentifiers
        await replan()
    }
}
