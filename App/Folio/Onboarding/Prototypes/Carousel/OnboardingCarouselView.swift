import SwiftUI

struct OnboardingCarouselView: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    let context: OnboardingPrototypeContext

    private var pages: [OnboardingCarouselPage] {
        [.welcome] + context.plannedSteps.map { .setup($0) }
    }

    private var currentPageIndex: Int {
        context.currentIndex.map { $0 + 1 } ?? 0
    }

    var body: some View {
        layout
            .animation(pageAnimation, value: currentPageIndex)
    }

    @ViewBuilder
    private var layout: some View {
        #if os(macOS)
        VStack(spacing: 0) {
            panel
                .frame(height: 250)
            indicator
            textStrip
                .frame(height: 280)
            Divider()
            HStack {
                Spacer()
                button
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .frame(width: 460)
        #else
        GeometryReader { proxy in
            VStack(spacing: 0) {
                panel
                    .frame(height: proxy.size.height * 0.55)
                indicator
                textStrip
            }
        }
        .safeAreaBar(edge: .bottom, spacing: 0) {
            button
                .frame(maxWidth: 560)
                .padding(24)
        }
        #endif
    }

    private var panel: some View {
        OnboardingCarouselPanel(pages: pages, currentIndex: currentPageIndex, features: context.features)
    }

    private var indicator: some View {
        OnboardingCarouselIndicator(pages: pages, currentIndex: currentPageIndex)
            .padding(.vertical, 18)
    }

    private var textStrip: some View {
        OnboardingCarouselTextStrip(pages: pages, currentIndex: currentPageIndex, features: context.features)
    }

    private var button: some View {
        OnboardingContinueButton(title: context.buttonTitle, action: context.advance)
            .accessibilityIdentifier(context.buttonIdentifier)
    }

    private var pageAnimation: Animation {
        reducesMotion ? .easeInOut(duration: 0.35) : .smooth(duration: 0.8, extraBounce: 0.05)
    }
}
