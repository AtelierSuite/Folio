import SwiftUI

struct OnboardingLivingTimelineText: View {
    let context: OnboardingPrototypeContext

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
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.smooth(duration: 0.45), value: context.step)
    }

    private var welcome: some View {
        VStack(alignment: .leading, spacing: Metrics.welcomeSpacing) {
            OnboardingHeader()
                .onboardingEntrance(delay: 0.5)
            VStack(alignment: .leading, spacing: Metrics.rowSpacing) {
                ForEach(Array(context.features.enumerated()), id: \.element) { index, feature in
                    OnboardingFeatureRow(feature: feature)
                        .onboardingEntrance(delay: 0.7 + Double(index) * 0.12)
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
                .foregroundStyle(.secondary)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private enum Metrics {
        #if os(macOS)
        static let welcomeSpacing: CGFloat = 20
        static let rowSpacing: CGFloat = 16
        #else
        static let welcomeSpacing: CGFloat = 28
        static let rowSpacing: CGFloat = 26
        #endif
    }
}
