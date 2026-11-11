import Planner
import SwiftUI

enum SettingsCategory: String, CaseIterable, Identifiable {
    case general
    case accounts
    case calendars
    case workWeek
    case flexTime
    case notes
    case notifications
    case eventNotifications
    case reminderNotifications
    case alarms
    case countdowns
    case sleep
    case medications
    case weather
    case search
    case privacy
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
        case .workWeek: String(localized: "WorkWeek.Title", table: "Week")
        case .flexTime: String(localized: "Title", table: "FlexTime")
        case .notes: String(localized: "Category.Notes", table: "Settings")
        case .notifications: String(localized: "Category.AllNotifications", table: "Settings")
        case .eventNotifications: String(localized: "Section.Events", table: "NotificationSounds")
        case .reminderNotifications: String(localized: "Section.Reminders", table: "NotificationSounds")
        case .alarms: String(localized: "Category.Alarms", table: "Settings")
        case .countdowns: String(localized: "Category.Countdowns", table: "Settings")
        case .sleep: String(localized: "Category.Sleep", table: "Settings")
        case .medications: String(localized: "Category.Medications", table: "Settings")
        case .weather: String(localized: "Category.Weather", table: "Settings")
        case .search: String(localized: "Category.Search", table: "Settings")
        case .privacy: String(localized: "Category.Privacy", table: "Settings")
        case .advanced: String(localized: "Category.Advanced", table: "Settings")
        #if DEBUG
        case .debug: String(localized: "Category.Debug", table: "Settings")
        #endif
        }
    }

    var systemImage: String {
        switch self {
        case .general: "gearshape.fill"
        case .accounts: "person.crop.circle.fill"
        case .calendars: "calendar"
        case .workWeek: "briefcase.fill"
        case .flexTime: "clock.arrow.circlepath"
        case .notes: "note.text"
        case .notifications: "bell.badge.fill"
        case .eventNotifications: "calendar.badge.clock"
        case .reminderNotifications: "checklist"
        case .alarms: "alarm.fill"
        case .countdowns: "timer"
        case .sleep: "bed.double.fill"
        case .medications: "pills.fill"
        case .weather: "cloud.sun.fill"
        case .search: "magnifyingglass"
        case .privacy: "hand.raised.fill"
        case .advanced: "ellipsis"
        #if DEBUG
        case .debug: "ladybug.fill"
        #endif
        }
    }

    var color: Color {
        switch self {
        case .general: .gray
        case .accounts: .blue
        case .calendars: .red
        case .workWeek: .brown
        case .flexTime: .mint
        case .notes: .yellow
        case .notifications: .pink
        case .eventNotifications: .red
        case .reminderNotifications: .purple
        case .alarms: .orange
        case .countdowns: .green
        case .sleep: .indigo
        case .medications: .teal
        case .weather: .cyan
        case .search: .gray
        case .privacy: .blue
        case .advanced: .gray
        #if DEBUG
        case .debug: .green
        #endif
        }
    }

    // Fraction of the icon size; some glyphs are drawn off-centre within their own bounds.
    var iconHorizontalOffset: CGFloat {
        switch self {
        case .privacy: -0.03
        default: 0
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
        case .alarms: capabilities.supports(.alarms)
        case .countdowns: capabilities.supports(.liveActivityCountdown)
        case .sleep: capabilities.supports(.sleep)
        case .medications: capabilities.supports(.medications)
        default: true
        }
    }
}
