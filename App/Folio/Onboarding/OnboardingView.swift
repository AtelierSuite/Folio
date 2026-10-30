import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    var body: some View {
        #if os(macOS)
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 28) {
                OnboardingHeader()
                featureList(spacing: 20)
            }
            .padding(.horizontal, 32)
            .padding(.top, 32)
            .padding(.bottom, 28)
            Divider()
            HStack {
                Spacer()
                OnboardingContinueButton(action: onFinish)
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
                OnboardingHeader()
                    .padding(.top, 24)
                featureList(spacing: 32)
            }
            .padding(24)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(alignment: .top) { accentGlow.ignoresSafeArea() }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            OnboardingContinueButton(action: onFinish)
                .frame(maxWidth: 560)
                .padding(24)
        }
        .presentationDragIndicator(.hidden)
        #endif
    }

    private func featureList(spacing: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(OnboardingFeature.allCases) { feature in
                OnboardingFeatureRow(feature: feature)
            }
        }
    }

    private var accentGlow: some View {
        LinearGradient(
            colors: [Color.accentColor.opacity(0.12), .clear],
            startPoint: .top,
            endPoint: .center
        )
    }
}
