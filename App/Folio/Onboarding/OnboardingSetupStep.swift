import Planner
import Foundation

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

    var title: String { localized("Title") }
    var description: String { localized("Description") }

    private func localized(_ suffix: String) -> String {
        let key = "Setup.\(rawValue.prefix(1).uppercased() + rawValue.dropFirst()).\(suffix)"
        return String(localized: String.LocalizationValue(key), table: "Onboarding")
    }
}
