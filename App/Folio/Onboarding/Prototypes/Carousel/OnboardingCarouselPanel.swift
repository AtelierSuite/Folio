import SwiftUI

struct OnboardingCarouselPanel: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    let pages: [OnboardingCarouselPage]
    let currentIndex: Int
    let features: [OnboardingFeature]

    var body: some View {
        ZStack {
            ForEach(Array(pages.enumerated()), id: \.element) { index, page in
                if abs(index - currentIndex) <= 1 {
                    OnboardingCarouselScene(page: page, features: features, isActive: index == currentIndex)
                        .onboardingCarouselParallax(
                            pageIndex: index,
                            currentIndex: currentIndex,
                            factor: reducesMotion ? 0 : 1
                        )
                        .opacity(reducesMotion && index != currentIndex ? 0 : 1)
                }
            }
        }
        .clipped()
        .background { backdrop }
        .accessibilityHidden(true)
    }

    private var backdrop: some View {
        ZStack {
            ForEach(Array(pages.enumerated()), id: \.element) { index, page in
                if abs(index - currentIndex) <= 1 {
                    OnboardingCarouselBackdrop(page: page)
                        .onboardingCarouselParallax(
                            pageIndex: index,
                            currentIndex: currentIndex,
                            factor: reducesMotion ? 0 : 0.45
                        )
                        .opacity(index == currentIndex ? 1 : 0)
                }
            }
        }
        .clipped()
        .padding(.bottom, -72)
        .ignoresSafeArea(edges: .top)
    }
}
