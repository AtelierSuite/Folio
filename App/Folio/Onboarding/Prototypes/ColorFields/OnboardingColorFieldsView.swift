import SwiftUI

struct OnboardingColorFieldsView: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    let context: OnboardingPrototypeContext

    var body: some View {
        #if os(macOS)
        VStack(spacing: 0) {
            page
                .padding(.horizontal, 32)
                .padding(.top, 28)
                .padding(.bottom, 24)
            OnboardingColorFieldsButton(context: context)
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
        }
        .frame(width: 460)
        .fixedSize(horizontal: false, vertical: true)
        .background { OnboardingColorFieldsBackground(step: context.step) }
        .animation(pageAnimation, value: context.step)
        #else
        ScrollView {
            page
                .padding(.horizontal, 28)
                .padding(.top, 24)
                .padding(.bottom, 24)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
        .safeAreaBar(edge: .bottom, spacing: 0) {
            OnboardingColorFieldsButton(context: context)
                .frame(maxWidth: 560)
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
        }
        .background { OnboardingColorFieldsBackground(step: context.step) }
        .animation(pageAnimation, value: context.step)
        #endif
    }

    private var page: some View {
        OnboardingColorFieldsPage(context: context)
            .id(context.step)
            .transition(pageTransition)
    }

    private var pageAnimation: Animation {
        .spring(duration: 0.7, bounce: 0.15)
    }

    private var pageTransition: AnyTransition {
        guard !reducesMotion else { return .opacity }
        return .asymmetric(
            insertion: .offset(x: 80).combined(with: .opacity),
            removal: .offset(x: -80).combined(with: .opacity)
        )
    }
}
