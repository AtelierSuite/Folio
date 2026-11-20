import SwiftUI

struct OnboardingMorphingIconLayout<Content: View>: View {
    let context: OnboardingPrototypeContext
    let glowColor: Color
    @ViewBuilder let content: Content

    var body: some View {
        #if os(macOS)
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                content
            }
            .padding(.horizontal, 32)
            .padding(.top, 24)
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
        .background(alignment: .top) { glow }
        #else
        ScrollView {
            VStack(spacing: 24) {
                content
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
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
        .background(alignment: .top) { glow.ignoresSafeArea() }
        #endif
    }

    private var button: some View {
        OnboardingContinueButton(title: context.buttonTitle, action: context.advance)
            .accessibilityIdentifier(context.buttonIdentifier)
    }

    private var glow: some View {
        RadialGradient(
            colors: [glowColor.opacity(0.24), .clear],
            center: .top,
            startRadius: 0,
            endRadius: 440
        )
        .animation(.smooth(duration: 0.8), value: glowColor)
    }
}
