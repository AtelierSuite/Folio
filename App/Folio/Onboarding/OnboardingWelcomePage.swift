import SwiftUI

struct OnboardingWelcomePage: View {
    let features: [OnboardingFeature]
    let onContinue: () -> Void

    var body: some View {
        OnboardingPageLayout(
            buttonTitle: String(localized: "Action.GetStarted", table: "Onboarding"),
            buttonIdentifier: "OnboardingGetStarted",
            action: onContinue
        ) {
            OnboardingFeatureFan(features: features)
            OnboardingHeader()
                .onboardingEntrance(delay: 0.25)
            VStack(alignment: .leading, spacing: Metrics.rowSpacing) {
                ForEach(Array(features.enumerated()), id: \.element) { index, feature in
                    OnboardingFeatureRow(feature: feature)
                        .onboardingEntrance(delay: 0.4 + Double(index) * 0.1)
                }
            }
        }
    }

    private enum Metrics {
        #if os(macOS)
        static let rowSpacing: CGFloat = 20
        #else
        static let rowSpacing: CGFloat = 32
        #endif
    }
}
