import SwiftUI

struct OnboardingPrototypeContext {
    let step: OnboardingStep
    let plannedSteps: [OnboardingSetupStep]
    let features: [OnboardingFeature]
    let advance: () -> Void
    var declinedSteps: Set<OnboardingSetupStep> = []

    var currentSetupStep: OnboardingSetupStep? {
        if case .setup(let setupStep) = step { setupStep } else { nil }
    }

    var currentIndex: Int? {
        currentSetupStep.flatMap { plannedSteps.firstIndex(of: $0) }
    }

    var completedSteps: [OnboardingSetupStep] {
        guard let currentIndex else { return [] }
        return Array(plannedSteps.prefix(currentIndex))
    }

    var buttonTitle: String {
        switch step {
        case .welcome: String(localized: "Action.GetStarted", table: "Onboarding")
        case .setup: String(localized: "Action.Continue", table: "Onboarding")
        }
    }

    var buttonIdentifier: String {
        switch step {
        case .welcome: "OnboardingGetStarted"
        case .setup: "OnboardingSetUp"
        }
    }
}
