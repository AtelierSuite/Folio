import Planner
import SwiftUI

enum SettingsCategory: String, CaseIterable, Identifiable {
    case general
    case accounts
    case calendars
    case reminders
    case alarms
    case workWeek
    case flexTime
    case notes
    case notifications
    case eventNotifications
    case reminderNotifications
    case wakeUpAlarm
    case travel
    case countdowns
    case focusLevel
    case workouts
    case sleep
    case medications
    case weather
    case search
    case advanced
    #if DEBUG
    case debug
    #endif

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: String(localized: "Category.General", table: "Settings")
        case .accounts: String(localized: "Category.Accounts", table: "Settings")
        case .calendars: String(localized: "Category.Calendars", table: "Settings")
        case .reminders: String(localized: "Settings.Header", table: "Reminders")
        case .alarms: String(localized: "Category.Alarms", table: "Settings")
        case .workWeek: String(localized: "WorkWeek.Title", table: "Week")
        case .flexTime: String(localized: "Title", table: "FlexTime")
        case .notes: String(localized: "Category.Notes", table: "Settings")
        case .notifications: String(localized: "Category.AllNotifications", table: "Settings")
        case .eventNotifications: String(localized: "Section.Events", table: "NotificationSounds")
        case .reminderNotifications: String(localized: "Section.Reminders", table: "NotificationSounds")
        case .wakeUpAlarm: String(localized: "Section", table: "WakeUpAlarms")
        case .travel: String(localized: "Category.Travel", table: "Settings")
        case .countdowns: String(localized: "Category.Countdowns", table: "Settings")
        case .focusLevel: String(localized: "Category.FocusLevel", table: "Settings")
        case .workouts: String(localized: "Category.Workouts", table: "Settings")
        case .sleep: String(localized: "Category.Sleep", table: "Settings")
        case .medications: String(localized: "Category.Medications", table: "Settings")
        case .weather: String(localized: "Category.Weather", table: "Settings")
        case .search: String(localized: "Category.Search", table: "Settings")
        case .advanced: String(localized: "Category.Advanced", table: "Settings")
        #if DEBUG
        case .debug: String(localized: "Category.Debug", table: "Settings")
        #endif
        }
    }

    var icon: ImageResource {
        switch self {
        case .general: .settingsGeneral
        case .accounts: .settingsAccounts
        case .calendars: .settingsCalendars
        case .reminders: .settingsReminders
        case .alarms: .settingsWakeUpAlarm
        case .workWeek: .settingsWorkWeek
        case .flexTime: .settingsFlexTime
        case .notes: .settingsNotes
        case .notifications: .settingsNotifications
        case .eventNotifications: .settingsEventNotifications
        case .reminderNotifications: .settingsReminderNotifications
        case .wakeUpAlarm: .settingsWakeUpAlarm
        case .travel: .settingsTravel
        case .countdowns: .settingsCountdowns
        case .focusLevel: .settingsFocusLevel
        case .workouts: .settingsWorkouts
        case .sleep: .settingsSleep
        case .medications: .settingsMedications
        case .weather: .settingsWeather
        case .search: .settingsSearch
        case .advanced: .settingsAdvanced
        #if DEBUG
        case .debug: .settingsDebug
        #endif
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .notifications: "NotificationSettingsLink"
        default: "SettingsCategory.\(rawValue)"
        }
    }

    func isAvailable(with capabilities: PlatformCapabilities) -> Bool {
        switch self {
        case .alarms, .wakeUpAlarm: capabilities.supports(.alarms)
        case .countdowns: capabilities.supports(.liveActivityCountdown)
        case .focusLevel, .sleep: capabilities.supports(.sleep)
        case .medications: capabilities.supports(.medications)
        case .workouts: capabilities.supports(.workouts)
        default: true
        }
    }
}
