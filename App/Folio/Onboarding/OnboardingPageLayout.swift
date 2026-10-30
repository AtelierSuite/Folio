import SwiftUI

struct OnboardingPageLayout<Content: View>: View {
    let buttonTitle: String
    let buttonIdentifier: String
    let action: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        #if os(macOS)
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 28) {
                content
            }
            .padding(.horizontal, 32)
            .padding(.top, 32)
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
        .background(alignment: .top) { accentGlow }
        #else
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                content
            }
            .padding(.horizontal, 24)
            .padding(.top, 48)
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
        .background(alignment: .top) { accentGlow.ignoresSafeArea() }
        #endif
    }

    private var button: some View {
        OnboardingContinueButton(title: buttonTitle, action: action)
            .accessibilityIdentifier(buttonIdentifier)
    }

    private var accentGlow: some View {
        LinearGradient(
            colors: [Color.accentColor.opacity(0.12), .clear],
            startPoint: .top,
            endPoint: .center
        )
    }
}
