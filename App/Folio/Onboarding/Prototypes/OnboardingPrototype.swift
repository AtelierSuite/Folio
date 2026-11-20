import Foundation

enum OnboardingPrototype: Int, CaseIterable {
    case timelineCards = 1
    case carousel
    case livingTimeline
    case colorFields
    case liquidGlass
    case folioPages
    case particles
    case productTour
    case journey
    case morphingIcon

    static let defaultsKey = "Onboarding.Prototype"

    static var selected: OnboardingPrototype {
        OnboardingPrototype(rawValue: UserDefaults.standard.integer(forKey: defaultsKey)) ?? .timelineCards
    }
}
