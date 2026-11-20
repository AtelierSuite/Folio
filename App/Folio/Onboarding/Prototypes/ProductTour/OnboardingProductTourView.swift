import SwiftUI

struct OnboardingProductTourView: View {
    let context: OnboardingPrototypeContext

    var body: some View {
        layout
            .animation(.smooth(duration: 0.55), value: context.step)
    }

    #if os(macOS)
    private var layout: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 24) {
                OnboardingProductTourStage(step: context.step)
                OnboardingProductTourCaption(context: context)
            }
            .padding(.horizontal, 32)
            .padding(.top, 28)
            .padding(.bottom, 28)
            Divider()
            HStack {
                Spacer()
                button
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .frame(width: 460)
        .fixedSize(horizontal: false, vertical: true)
    }
    #else
    private var layout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                OnboardingProductTourStage(step: context.step)
                OnboardingProductTourCaption(context: context)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 24)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollEdgeEffectStyle(.soft, for: .bottom)
        .safeAreaBar(edge: .bottom, spacing: 0) {
            button
                .frame(maxWidth: 560)
                .padding(24)
        }
    }
    #endif

    private var button: some View {
        OnboardingContinueButton(title: context.buttonTitle, action: context.advance)
            .accessibilityIdentifier(context.buttonIdentifier)
    }
}
