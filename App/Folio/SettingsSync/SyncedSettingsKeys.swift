import Foundation
import Planner

/// Preferences that follow the user across devices. Device-bound state stays out: calendar and item
/// identifiers (they differ per device), permission-gated feature switches, caches, ledgers, health
/// settings, folder bookmarks and window state.
enum SyncedSettingsKeys {
    static var domains: [SyncedDefaultsDomain] {
        [
            SyncedDefaultsDomain(defaults: AppGroup.userDefaults, keys: appGroupKeys),
            SyncedDefaultsDomain(defaults: .standard, keys: appKeys)
        ]
    }

    private static var appGroupKeys: [String] {
        weatherKeys + flexTimeKeys + notificationKeys + travelKeys + wakeUpAlarmKeys + calendarKeys + birthdayKeys
    }

    private static let birthdayKeys = [
        BirthdaySettings.alertsOnTheDayKey,
        BirthdaySettings.alertsDayBeforeKey
    ]

    private static let weatherKeys = [
        WeatherSettings.isEnabledKey,
        WeatherSettings.locationModeKey,
        WeatherSettings.chosenPlaceKey
    ]

    private static var flexTimeKeys: [String] {
        FlexTimeDayKind.allCases.map { FlexTimeStorage.dayKindKeyPrefix + $0.rawValue } + [
            FlexTimeStorage.delaysKey,
            FlexTimeStorage.excludedCalendarsKey,
            FlexTimeStorage.promptedDayKey
        ]
    }

    private static let notificationKeys = [
        NotificationSnoozeSettings.shortMinutesKey,
        NotificationSnoozeSettings.longMinutesKey,
        AlarmSnoozeSettings.minutesKey,
        NotificationSettings.includesEventsKey,
        NotificationSettings.includesRemindersKey,
        NotificationSettings.keepsEventAlertsKey,
        NotificationSoundSettings.eventSoundKey,
        NotificationSoundSettings.reminderSoundKey
    ]

    private static let travelKeys = [
        TravelTimeSettings.transportKey,
        LeaveAlertSettings.transportKey,
        LeaveAlertSettings.ringsAsAlarmKey,
        LeaveAlertSettings.alarmSoundKey
    ]

    private static let wakeUpAlarmKeys = [
        WakeUpAlarmSettings.leadMinutesKey,
        WakeUpAlarmSettings.earliestMinutesKey,
        WakeUpAlarmSettings.latestEventMinutesKey,
        WakeUpAlarmSettings.skipsHolidaysKey,
        WakeUpAlarmSettings.addsTravelTimeKey,
        WakeUpAlarmSettings.transportKey,
        WakeUpAlarmSettings.soundKey
    ]

    private static let calendarKeys = [
        DayHighlightSettings.highlightsWeekendsKey,
        DayHighlightSettings.highlightsHolidaysKey,
        DayHighlightSettings.holidayRegionKey,
        AlternateCalendar.storageKey,
        SecondaryTimeZoneSettings.isEnabledKey,
        SecondaryTimeZoneSettings.identifierKey,
        EventTapSettings.behaviorKey,
        CountdownSettings.countsToStartKey,
        CountdownSettings.countsToEndKey,
        SearchRangeStorage.monthsBackKey,
        SearchRangeStorage.monthsAheadKey,
        LinkedNoteSettings.writesLinkToEventKey,
        WorkWeekStorage.workdaysKey,
        EventLocationSettings.defaultLocationKey,
        EventLocationSettings.savedLocationsKey,
        ReminderSettings.overduePolicyKey,
        CalendarVisibilityStorage.hidesDeclinedEventsKey
    ]

    private static let appKeys = [
        TimelineSettings.compressesTextKey,
        MonthSettings.showsWeekNumbersKey,
        DragSettings.snapMinutesKey,
        CalendarWeekLayout.storageKey,
        "Calendar.MultiDayCount",
        NoteSortOrder.storageKey,
        WeatherNightSettings.shadesNightKey,
        EnergyLevelSettings.bleedsUnderEventsKey
    ]
}
