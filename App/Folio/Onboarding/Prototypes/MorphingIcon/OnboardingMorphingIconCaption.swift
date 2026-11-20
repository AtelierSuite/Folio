import SwiftUI

struct OnboardingMorphingIconCaption: View {
    let context: OnboardingPrototypeContext
    let highlightedFeature: OnboardingFeature?

    var body: some View {
        switch context.step {
        case .welcome:
            VStack(spacing: Metrics.welcomeSpacing) {
                OnboardingMorphingIconWelcomeTitle()
                    .onboardingEntrance(delay: 0.2)
                OnboardingMorphingIconFeatureList(
                    features: context.features, highlightedFeature: highlightedFeature
                )
            }
        case .setup(let step):
            VStack(spacing: 12) {
                OnboardingMorphingIconProgress(steps: context.plannedSteps, current: step)
                Text(step.title)
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("OnboardingSetupTitle")
                Text(step.description)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
        }
    }

    private enum Metrics {
        #if os(macOS)
        static let welcomeSpacing: CGFloat = 20
        #else
        static let welcomeSpacing: CGFloat = 28
        #endif
    }
}

struct OnboardingMorphingIconWelcomeTitle: View {
    private static let appName = "Folio"

    var body: some View {
        Text(title)
            .font(.largeTitle)
            .fontWeight(.black)
            .multilineTextAlignment(.center)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier("OnboardingTitle")
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
    }

    private var title: AttributedString {
        var title = AttributedString(String(localized: "Welcome.Title", table: "Onboarding"))
        if let range = title.range(of: Self.appName) {
            title[range].foregroundColor = .accentColor
        }
        return title
    }
}

struct OnboardingMorphingIconProgress: View {
    let steps: [OnboardingSetupStep]
    let current: OnboardingSetupStep

    var body: some View {
        HStack(spacing: 6) {
            ForEach(steps) { step in
                Capsule()
                    .fill(color(for: step))
                    .frame(width: step == current ? 22 : 7, height: 7)
            }
        }
        .accessibilityHidden(true)
    }

    private func color(for step: OnboardingSetupStep) -> Color {
        let index = steps.firstIndex(of: step) ?? 0
        let currentIndex = steps.firstIndex(of: current) ?? 0
        guard index <= currentIndex else { return .secondary.opacity(0.25) }
        return OnboardingMorphingIconFace(step: step).colors.last ?? .accentColor
    }
}
