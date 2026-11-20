import SwiftUI

struct OnboardingJourneyLayout<Content: View>: View {
    let buttonTitle: String
    let buttonIdentifier: String
    let glow: Color
    let action: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        #if os(macOS)
        VStack(spacing: 0) {
            content
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
        .background(alignment: .top) { glowGradient }
        #else
        ScrollView {
            content
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .padding(.bottom, 24)
                .frame(maxWidth: 860)
                .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollEdgeEffectStyle(.soft, for: .bottom)
        .safeAreaBar(edge: .bottom, spacing: 0) {
            button
                .frame(maxWidth: 560)
                .padding(24)
        }
        .background(alignment: .top) { glowGradient.ignoresSafeArea() }
        #endif
    }

    private var button: some View {
        OnboardingContinueButton(title: buttonTitle, action: action)
            .accessibilityIdentifier(buttonIdentifier)
    }

    private var glowGradient: some View {
        LinearGradient(colors: [glow.opacity(0.16), .clear], startPoint: .top, endPoint: .center)
    }
}
