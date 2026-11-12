import Planner
import SwiftUI

enum OnboardingSetupStep: String, CaseIterable, Identifiable {
    case calendar
    case reminders
    case alerts
    case weather
    case sleep

    var id: String { rawValue }

    var permission: PermissionKind {
        switch self {
        case .calendar: .calendar
        case .reminders: .reminders
        case .alerts: .notifications
        case .weather: .location
        case .sleep: .health
        }
    }

    var systemImage: String {
        switch self {
        case .calendar: "calendar"
        case .reminders: "checklist"
        case .alerts: "bell.badge.fill"
        case .weather: "cloud.sun.fill"
        case .sleep: "bed.double.fill"
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .calendar: [.pink, .red]
        case .reminders: [.purple, .pink]
        case .alerts: [.orange, .red]
        case .weather: [.cyan, .blue]
        case .sleep: [.teal, .indigo]
        }
    }

    var title: String { localized("Title") }
    var description: String { localized("Description") }

    private func localized(_ suffix: String) -> String {
        let key = "Setup.\(rawValue.prefix(1).uppercased() + rawValue.dropFirst()).\(suffix)"
        return String(localized: String.LocalizationValue(key), table: "Onboarding")
    }
}
