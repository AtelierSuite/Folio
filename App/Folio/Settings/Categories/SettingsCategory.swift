import Planner
import SwiftUI

enum SettingsCategory: String, CaseIterable, Identifiable {
    case general
    case calendars
    case notes
    case notifications
    case sleep
    case weather
    case searchAndPrivacy
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
        case .sleep: String(localized: "Category.Sleep", table: "Settings")
        case .weather: String(localized: "Category.Weather", table: "Settings")
        case .searchAndPrivacy: String(localized: "Category.SearchAndPrivacy", table: "Settings")
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
        case .sleep: "bed.double.fill"
        case .weather: "cloud.sun.fill"
        case .searchAndPrivacy: "hand.raised.fill"
        #if DEBUG
        case .debug: "ladybug.fill"
        #endif
        }
    }

    var color: Color {
        switch self {
        case .general: .gray
        case .calendars: .red
        case .notes: .orange
        case .notifications: .pink
        case .sleep: .indigo
        case .weather: .cyan
        case .searchAndPrivacy: .blue
        #if DEBUG
        case .debug: .green
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
        case .sleep: capabilities.supports(.sleep)
        default: true
        }
    }

    static var groups: [[SettingsCategory]] {
        var groups: [[SettingsCategory]] = [
            [.general, .calendars, .notes],
            [.notifications, .sleep, .searchAndPrivacy],
            [.weather]
        ]
        #if DEBUG
        groups.append([.debug])
        #endif
        return groups
    }
}
