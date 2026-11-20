import SwiftUI

struct OnboardingCarouselTextStrip: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    let pages: [OnboardingCarouselPage]
    let currentIndex: Int
    let features: [OnboardingFeature]

    var body: some View {
        ZStack(alignment: .top) {
            ForEach(Array(pages.enumerated()), id: \.element) { index, page in
                if abs(index - currentIndex) <= 1 {
                    let isCurrent = index == currentIndex
                    ScrollView {
                        OnboardingCarouselText(page: page, features: features)
                            .padding(.horizontal, 28)
                            .padding(.bottom, 16)
                            .frame(maxWidth: 560, alignment: .leading)
                            .frame(maxWidth: .infinity)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .onboardingCarouselParallax(
                        pageIndex: index,
                        currentIndex: currentIndex,
                        factor: reducesMotion ? 0 : 0.55
                    )
                    .opacity(isCurrent ? 1 : 0)
                    .allowsHitTesting(isCurrent)
                    .accessibilityHidden(!isCurrent)
                }
            }
        }
        .clipped()
    }
}

private struct OnboardingCarouselText: View {
    let page: OnboardingCarouselPage
    let features: [OnboardingFeature]

    var body: some View {
        switch page {
        case .welcome:
            VStack(alignment: .leading, spacing: 20) {
                OnboardingHeader()
                ForEach(features) { feature in
                    OnboardingCarouselFeatureRow(feature: feature)
                }
            }
        case .setup(let setupStep):
            VStack(alignment: .leading, spacing: 10) {
                Text(setupStep.title)
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("OnboardingSetupTitle")
                Text(setupStep.description)
                    .foregroundStyle(.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct OnboardingCarouselFeatureRow: View {
    let feature: OnboardingFeature

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: feature.systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(
                    LinearGradient(colors: feature.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: .rect(cornerRadius: 9, style: .continuous)
                )
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .fontWeight(.bold)
                Text(feature.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}
