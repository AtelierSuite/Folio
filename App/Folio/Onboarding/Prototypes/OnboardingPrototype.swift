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
    case finalConcept

    static let defaultsKey = "Onboarding.Prototype"

    var excludedSteps: Set<OnboardingSetupStep> {
        self == .finalConcept ? [.sleep] : [.alarms]
    }

    var excludedFeatures: Set<OnboardingFeature> {
        self == .finalConcept ? [.sleep] : []
    }

    static var selected: OnboardingPrototype {
        OnboardingPrototype(rawValue: UserDefaults.standard.integer(forKey: defaultsKey)) ?? .finalConcept
    }
}
