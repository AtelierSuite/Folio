import SwiftUI

struct OnboardingMorphingIconFeatureList: View {
    let features: [OnboardingFeature]
    let highlightedFeature: OnboardingFeature?
    @Namespace private var highlight

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.rowSpacing) {
            ForEach(Array(features.enumerated()), id: \.element) { index, feature in
                OnboardingFeatureRow(feature: feature)
                    .padding(.horizontal, 12)
                    .padding(.vertical, Metrics.rowPadding)
                    .background {
                        if feature == highlightedFeature {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill((feature.gradientColors.first ?? .accentColor).opacity(0.12))
                                .matchedGeometryEffect(id: "highlight", in: highlight)
                        }
                    }
                    .onboardingEntrance(delay: 0.35 + Double(index) * 0.1)
            }
        }
        .animation(.spring(duration: 0.5, bounce: 0.25), value: highlightedFeature)
    }

    private enum Metrics {
        #if os(macOS)
        static let rowSpacing: CGFloat = 4
        static let rowPadding: CGFloat = 8
        #else
        static let rowSpacing: CGFloat = 8
        static let rowPadding: CGFloat = 12
        #endif
    }
}
