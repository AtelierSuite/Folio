import SwiftUI

struct OnboardingJourneyWelcome: View {
    let features: [OnboardingFeature]
    let steps: [OnboardingSetupStep]
    let namespace: Namespace.ID

    var body: some View {
        #if os(macOS)
        VStack(alignment: .leading, spacing: 24) {
            OnboardingHeader()
                .onboardingEntrance()
            HStack(alignment: .center, spacing: 16) {
                featureRows
                if !steps.isEmpty {
                    OnboardingJourneyPreview(steps: steps, namespace: namespace, swing: 0.18)
                        .frame(width: 96)
                }
            }
        }
        #else
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: 40) {
                intro
                    .frame(minWidth: 380, idealWidth: 380, maxWidth: .infinity)
                if !steps.isEmpty {
                    OnboardingJourneyPreview(steps: steps, namespace: namespace, spacing: 76, badgeDiameter: 52)
                        .frame(width: 220)
                }
            }
            VStack(alignment: .leading, spacing: 36) {
                intro
                if !steps.isEmpty {
                    OnboardingJourneyPreview(steps: steps, namespace: namespace)
                }
            }
        }
        #endif
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 32) {
            OnboardingHeader()
                .onboardingEntrance()
            featureRows
        }
    }

    private var featureRows: some View {
        VStack(alignment: .leading, spacing: Metrics.rowSpacing) {
            ForEach(Array(features.enumerated()), id: \.element) { index, feature in
                OnboardingFeatureRow(feature: feature)
                    .onboardingEntrance(delay: 0.15 + Double(index) * 0.08)
            }
        }
    }

    private enum Metrics {
        #if os(macOS)
        static let rowSpacing: CGFloat = 18
        #else
        static let rowSpacing: CGFloat = 26
        #endif
    }
}
