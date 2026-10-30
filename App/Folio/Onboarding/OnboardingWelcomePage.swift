import Planner
import SwiftUI

struct OnboardingWelcomePage: View {
    @Environment(\.platformCapabilities) private var capabilities
    let onContinue: () -> Void

    var body: some View {
        OnboardingPageLayout(
            buttonTitle: String(localized: "Action.GetStarted", table: "Onboarding"),
            buttonIdentifier: "OnboardingGetStarted",
            action: onContinue
        ) {
            OnboardingHeader()
            VStack(alignment: .leading, spacing: Metrics.rowSpacing) {
                ForEach(features) { feature in
                    OnboardingFeatureRow(feature: feature)
                }
            }
        }
    }

    private var features: [OnboardingFeature] {
        OnboardingFeature.allCases.filter { feature in
            feature.requiredPlatformFeature.map(capabilities.supports) ?? true
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
