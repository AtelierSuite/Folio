import SwiftUI

enum OnboardingPage: String, CaseIterable, Identifiable {
    case welcome
    case calendar
    case notes
    case privacy

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .welcome: "book.pages"
        case .calendar: "calendar.day.timeline.left"
        case .notes: "note.text"
        case .privacy: "hand.raised"
        }
    }

    var title: String {
        localized("Title")
    }

    var description: String {
        localized("Description")
    }

    var next: OnboardingPage? {
        let pages = Self.allCases
        guard let index = pages.firstIndex(of: self), index + 1 < pages.count else { return nil }
        return pages[index + 1]
    }

    var previous: OnboardingPage? {
        let pages = Self.allCases
        guard let index = pages.firstIndex(of: self), index > 0 else { return nil }
        return pages[index - 1]
    }

    private func localized(_ suffix: String) -> String {
        let key = "Page.\(rawValue.prefix(1).uppercased() + rawValue.dropFirst()).\(suffix)"
        return String(localized: String.LocalizationValue(key), table: "Onboarding")
    }
}
