import SwiftUI

struct OnboardingProductTourCaption: View {
    let context: OnboardingPrototypeContext

    var body: some View {
        ZStack(alignment: .topLeading) {
            switch context.step {
            case .welcome:
                OnboardingProductTourWelcomeCaption(features: context.features)
                    .transition(.opacity.combined(with: .offset(x: -40)))
            case .setup(let setupStep):
                OnboardingProductTourStepCaption(step: setupStep)
                    .id(setupStep)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .offset(x: 40)),
                        removal: .opacity.combined(with: .offset(x: -40))
                    ))
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

private struct OnboardingProductTourWelcomeCaption: View {
    let features: [OnboardingFeature]

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.spacing) {
            OnboardingHeader()
                .onboardingEntrance(delay: 0.9)
            ForEach(Array(features.enumerated()), id: \.element) { index, feature in
                OnboardingFeatureRow(feature: feature)
                    .onboardingEntrance(delay: 1.6 + Double(index) * 0.12)
            }
        }
    }

    private enum Metrics {
        #if os(macOS)
        static let spacing: CGFloat = 18
        #else
        static let spacing: CGFloat = 28
        #endif
    }
}

private struct OnboardingProductTourStepCaption: View {
    let step: OnboardingSetupStep

    var body: some View {
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
    }
}
