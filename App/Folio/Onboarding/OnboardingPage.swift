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
        String(localized: String.LocalizationValue("Page.\(keyName).Title"), table: "Onboarding")
    }

    var description: String {
        String(localized: String.LocalizationValue("Page.\(keyName).Description"), table: "Onboarding")
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

    private var keyName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }
}
