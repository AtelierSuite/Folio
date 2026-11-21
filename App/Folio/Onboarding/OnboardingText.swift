import SwiftUI

struct OnboardingText: View {
    let context: OnboardingContext

    var body: some View {
        ZStack(alignment: .topLeading) {
            switch context.step {
            case .welcome:
                welcome
                    .transition(.blurReplace)
            case .setup(let setupStep):
                setup(setupStep)
                    .id(setupStep)
                    .transition(.blurReplace)
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.smooth(duration: 0.45), value: context.step)
    }

    private var welcome: some View {
        VStack(alignment: .leading, spacing: Metrics.welcomeSpacing) {
            Text(String(localized: "Welcome.Title", table: "Onboarding"))
                .font(.largeTitle)
                .fontWeight(.black)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("OnboardingTitle")
                .fixedSize(horizontal: false, vertical: true)
                .onboardingEntrance(delay: 0.4)
            VStack(alignment: .leading, spacing: Metrics.rowSpacing) {
                ForEach(Array(context.features.enumerated()), id: \.element) { index, feature in
                    OnboardingFeatureRow(feature: feature)
                        .onboardingEntrance(delay: 0.55 + Double(index) * 0.1)
                }
            }
        }
    }

    private func setup(_ setupStep: OnboardingSetupStep) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(setupStep.title)
                .font(.largeTitle)
                .fontWeight(.black)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("OnboardingSetupTitle")
            Text(setupStep.description)
                .opacity(0.85)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private enum Metrics {
        #if os(macOS)
        static let welcomeSpacing: CGFloat = 18
        static let rowSpacing: CGFloat = 14
        #else
        static let welcomeSpacing: CGFloat = 24
        static let rowSpacing: CGFloat = 20
        #endif
    }
}

private struct OnboardingFeatureRow: View {
    let feature: OnboardingFeature

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: feature.systemImage)
                .font(.system(size: Metrics.symbolSize, weight: .semibold))
                .frame(width: Metrics.iconSize, height: Metrics.iconSize)
            VStack(alignment: .leading, spacing: 3) {
                Text(feature.title)
                    .fontWeight(.bold)
                Text(feature.description)
                    .font(.subheadline)
                    .opacity(0.82)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    private enum Metrics {
        #if os(macOS)
        static let symbolSize: CGFloat = 23
        static let iconSize: CGFloat = 36
        #else
        static let symbolSize: CGFloat = 30
        static let iconSize: CGFloat = 46
        #endif
    }
}
