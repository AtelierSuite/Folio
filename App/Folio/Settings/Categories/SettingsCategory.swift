import Planner
import SwiftUI

enum SettingsCategory: String, CaseIterable, Identifiable {
    case general
    case calendars
    case notes
    case notifications
    case alarms
    case sleep
    case weather
    case search
    case privacy
    #if DEBUG
    case debug
    #endif

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: String(localized: "Category.General", table: "Settings")
        case .calendars: String(localized: "Category.Calendars", table: "Settings")
        case .notes: String(localized: "Category.Notes", table: "Settings")
        case .notifications: String(localized: "Category.Notifications", table: "Settings")
        case .alarms: String(localized: "Category.Alarms", table: "Settings")
        case .sleep: String(localized: "Category.Sleep", table: "Settings")
        case .weather: String(localized: "Category.Weather", table: "Settings")
        case .search: String(localized: "Category.Search", table: "Settings")
        case .privacy: String(localized: "Category.Privacy", table: "Settings")
        #if DEBUG
        case .debug: String(localized: "Category.Debug", table: "Settings")
        #endif
        }
    }

    var systemImage: String {
        switch self {
        case .general: "gearshape.fill"
        case .calendars: "calendar"
        case .notes: "note.text"
        case .notifications: "bell.badge.fill"
        case .alarms: "alarm.fill"
        case .sleep: "bed.double.fill"
        case .weather: "cloud.sun.fill"
        case .search: "magnifyingglass"
        case .privacy: "hand.raised.fill"
        #if DEBUG
        case .debug: "ladybug.fill"
        #endif
        }
    }

    var color: Color {
        switch self {
        case .general: .gray
        case .calendars: .red
        case .notes: .blue
        case .notifications: .pink
        case .alarms: .orange
        case .sleep: .indigo
        case .weather: .cyan
        case .search: .purple
        case .privacy: .blue
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
        case .sleep: capabilities.supports(.sleep)
        default: true
        }
    }

    static var groups: [[SettingsCategory]] {
        groups(including: [.search])
    }

    static var windowGroups: [[SettingsCategory]] {
        groups(including: [.search, .privacy])
    }

    private static func groups(including systemCategories: [SettingsCategory]) -> [[SettingsCategory]] {
        var groups: [[SettingsCategory]] = [
            [.general, .calendars, .notes],
            [.weather],
            [.notifications, .alarms, .sleep] + systemCategories
        ]
        #if DEBUG
        groups.append([.debug])
        #endif
        return groups
    }
}
