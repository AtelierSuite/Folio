import SwiftUI

struct OnboardingFeatureRow: View {
    let feature: OnboardingFeature

    var body: some View {
        HStack(alignment: .center, spacing: Metrics.spacing) {
            Image(systemName: feature.systemImage)
                .font(.system(size: Metrics.symbolSize))
                .foregroundStyle(LinearGradient(
                    colors: feature.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: Metrics.iconFrame, height: Metrics.iconFrame)
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .fontWeight(.bold)
                Text(feature.description)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    private enum Metrics {
        #if os(macOS)
        static let spacing: CGFloat = 14
        static let symbolSize: CGFloat = 30
        static let iconFrame: CGFloat = 40
        #else
        static let spacing: CGFloat = 16
        static let symbolSize: CGFloat = 40
        static let iconFrame: CGFloat = 56
        #endif
    }
}
