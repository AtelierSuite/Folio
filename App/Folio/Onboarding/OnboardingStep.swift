enum OnboardingStep: Hashable {
    case welcome
    case setup(OnboardingSetupStep)
}
