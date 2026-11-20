import SwiftUI

struct OnboardingJourneySetup: View {
    let step: OnboardingSetupStep
    let steps: [OnboardingSetupStep]
    let isLanded: Bool
    let segmentProgress: Double
    let namespace: Namespace.ID

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.spacing) {
            OnboardingJourneyTrail(
                steps: steps,
                currentStep: step,
                isCurrentLanded: isLanded,
                segmentProgress: segmentProgress,
                namespace: namespace
            )
            OnboardingJourneyHero(step: step, isBadgeLanded: isLanded, namespace: namespace)
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .id(step)
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .offset(y: 14)),
                removal: .opacity
            ))
        }
    }

    private enum Metrics {
        #if os(macOS)
        static let spacing: CGFloat = 18
        #else
        static let spacing: CGFloat = 26
        #endif
    }
}
