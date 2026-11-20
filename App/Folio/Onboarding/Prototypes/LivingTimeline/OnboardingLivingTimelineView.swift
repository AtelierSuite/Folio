import SwiftUI

struct OnboardingLivingTimelineView: View {
    let context: OnboardingPrototypeContext

    var body: some View {
        #if os(macOS)
        VStack(spacing: 0) {
            content
                .padding(.horizontal, 28)
                .padding(.top, 28)
                .padding(.bottom, 24)
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
        #else
        ScrollView {
            content
                .padding(.horizontal, 24)
                .padding(.top, 32)
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
        #endif
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingLivingTimelineCard(context: context)
            OnboardingLivingTimelineStepIcons(context: context)
                .padding(.top, 16)
                .padding(.bottom, 24)
            OnboardingLivingTimelineText(context: context)
        }
    }

    private var button: some View {
        OnboardingContinueButton(title: context.buttonTitle, action: context.advance)
            .accessibilityIdentifier(context.buttonIdentifier)
    }
}
