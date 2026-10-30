import SwiftUI

enum OnboardingFeature: String, CaseIterable, Identifiable {
    case calendar
    case notes
    case privacy

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .calendar: "calendar.day.timeline.left"
        case .notes: "note.text"
        case .privacy: "hand.raised.fill"
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .calendar: [.pink, .red]
        case .notes: [.yellow, .orange]
        case .privacy: [.cyan, .blue]
        }
    }

    var title: String {
        localized("Title")
    }

    var description: String {
        localized("Description")
    }

    private func localized(_ suffix: String) -> String {
        let key = "Feature.\(rawValue.prefix(1).uppercased() + rawValue.dropFirst()).\(suffix)"
        return String(localized: String.LocalizationValue(key), table: "Onboarding")
    }
}
