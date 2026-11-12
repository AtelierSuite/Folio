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
            Image(systemName: step.systemImage)
                .font(.system(size: Metrics.symbolSize))
                .foregroundStyle(LinearGradient(
                    colors: step.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .accessibilityHidden(true)
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

    private enum Metrics {
        #if os(macOS)
        static let symbolSize: CGFloat = 44
        #else
        static let symbolSize: CGFloat = 64
        #endif
    }
}
