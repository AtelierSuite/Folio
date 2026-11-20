import SwiftUI

struct OnboardingFolioPagesCaption: View {
    let step: OnboardingStep
    let features: [OnboardingFeature]
    @Environment(\.accessibilityReduceMotion) private var reducesMotion

    var body: some View {
        ZStack(alignment: .topLeading) {
            Group {
                switch step {
                case .welcome: welcome
                case .setup(let setupStep): setup(setupStep)
                }
            }
            .id(step)
            .transition(transition)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var welcome: some View {
        VStack(alignment: .leading, spacing: OnboardingFolioPagesMetrics.rowSpacing) {
            OnboardingHeader()
                .onboardingEntrance(delay: 0.9)
            ForEach(Array(features.enumerated()), id: \.element) { index, feature in
                OnboardingFeatureRow(feature: feature)
                    .onboardingEntrance(delay: 1.05 + Double(index) * 0.1)
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

    private var transition: AnyTransition {
        if reducesMotion { return .opacity }
        return .asymmetric(
            insertion: .opacity.combined(with: .offset(x: 28)),
            removal: .opacity.combined(with: .offset(x: -28))
        )
    }
}
