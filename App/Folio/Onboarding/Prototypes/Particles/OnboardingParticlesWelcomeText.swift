import SwiftUI

struct OnboardingParticlesWelcomeText: View {
    let features: [OnboardingFeature]

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.spacing) {
            OnboardingHeader()
            VStack(alignment: .leading, spacing: Metrics.rowSpacing) {
                ForEach(features) { feature in
                    OnboardingFeatureRow(feature: feature)
                }
            }
        }
    }

    private enum Metrics {
        #if os(macOS)
        static let spacing: CGFloat = 20
        static let rowSpacing: CGFloat = 16
        #else
        static let spacing: CGFloat = 28
        static let rowSpacing: CGFloat = 24
        #endif
    }
}
