import SwiftUI

struct OnboardingSetupPage: View {
    let step: OnboardingSetupStep
    let onSetUp: () -> Void
    let onSkip: () -> Void

    var body: some View {
        OnboardingPageLayout(
            buttonTitle: String(localized: "Action.Continue", table: "Onboarding"),
            buttonIdentifier: "OnboardingSetUp",
            action: onSetUp,
            secondaryTitle: String(localized: "Action.SkipForNow", table: "Onboarding"),
            secondaryAction: onSkip
        ) {
            OnboardingGraphic(step: step)
                .id(step)
            VStack(alignment: .leading, spacing: 8) {
                Text(step.title)
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("OnboardingSetupTitle")
                Text(step.description)
                    .foregroundStyle(.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}
