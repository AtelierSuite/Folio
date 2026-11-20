import SwiftUI

struct OnboardingFinalView: View {
    let context: OnboardingPrototypeContext

    var body: some View {
        #if os(macOS)
        VStack(spacing: 0) {
            content
                .padding(.horizontal, 28)
                .padding(.top, 20)
                .padding(.bottom, 20)
            OnboardingFinalButton(context: context)
                .padding(.horizontal, 28)
                .padding(.bottom, 24)
        }
        .frame(width: 460)
        .fixedSize(horizontal: false, vertical: true)
        .background { OnboardingFinalBackground(step: context.step) }
        #else
        ScrollView {
            content
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaBar(edge: .bottom, spacing: 0) {
            OnboardingFinalButton(context: context)
                .frame(maxWidth: 560)
                .padding(24)
        }
        .background { OnboardingFinalBackground(step: context.step) }
        #endif
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingFinalTrail(context: context)
            OnboardingFinalTimeline(context: context)
                .padding(.top, 12)
            OnboardingFinalText(context: context)
                .padding(.top, Metrics.textSpacing)
        }
    }

    private enum Metrics {
        #if os(macOS)
        static let textSpacing: CGFloat = 20
        #else
        static let textSpacing: CGFloat = 28
        #endif
    }
}
