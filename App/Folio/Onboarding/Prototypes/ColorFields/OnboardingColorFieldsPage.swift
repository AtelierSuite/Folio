import SwiftUI

struct OnboardingColorFieldsPage: View {
    let context: OnboardingPrototypeContext

    var body: some View {
        VStack(spacing: Metrics.spacing) {
            OnboardingColorFieldsHero(context: context)
                .frame(height: Metrics.heroHeight)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
            switch context.step {
            case .welcome:
                OnboardingColorFieldsWelcomeText(features: context.features)
            case .setup(let setupStep):
                setupText(for: setupStep)
            }
        }
        .foregroundStyle(.white)
    }

    private func setupText(for setupStep: OnboardingSetupStep) -> some View {
        VStack(spacing: 12) {
            Text(setupStep.title)
                .font(Metrics.titleFont)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("OnboardingSetupTitle")
            Text(setupStep.description)
                .font(Metrics.bodyFont)
                .foregroundStyle(.white.opacity(0.8))
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
    }

    enum Metrics {
        static let titleFont: Font = .system(.largeTitle, weight: .heavy)
        #if os(macOS)
        static let spacing: CGFloat = 20
        static let heroHeight: CGFloat = 220
        static let bodyFont: Font = .body
        #else
        static let spacing: CGFloat = 28
        static let heroHeight: CGFloat = 300
        static let bodyFont: Font = .title3
        #endif
    }
}

private struct OnboardingColorFieldsWelcomeText: View {
    let features: [OnboardingFeature]

    var body: some View {
        VStack(spacing: OnboardingColorFieldsPage.Metrics.spacing) {
            Text(String(localized: "Welcome.Title", table: "Onboarding"))
                .font(OnboardingColorFieldsPage.Metrics.titleFont)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("OnboardingTitle")
            VStack(alignment: .leading, spacing: Metrics.rowSpacing) {
                ForEach(features) { feature in
                    OnboardingColorFieldsFeatureRow(feature: feature)
                }
            }
        }
    }

    private enum Metrics {
        #if os(macOS)
        static let rowSpacing: CGFloat = 16
        #else
        static let rowSpacing: CGFloat = 24
        #endif
    }
}

private struct OnboardingColorFieldsFeatureRow: View {
    let feature: OnboardingFeature

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: feature.systemImage)
                .font(.system(size: Metrics.symbolSize, weight: .semibold))
                .frame(width: Metrics.iconFrame, height: Metrics.iconFrame)
                .background(.white.opacity(0.16), in: .rect(cornerRadius: Metrics.iconFrame * 0.3))
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .fontWeight(.bold)
                Text(feature.description)
                    .foregroundStyle(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    private enum Metrics {
        #if os(macOS)
        static let symbolSize: CGFloat = 18
        static let iconFrame: CGFloat = 36
        #else
        static let symbolSize: CGFloat = 22
        static let iconFrame: CGFloat = 46
        #endif
    }
}
