import SwiftUI

struct OnboardingFeatureFan: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var isFanned = false
    @State private var isFloating = false
    let features: [OnboardingFeature]

    var body: some View {
        ZStack {
            ForEach(Array(features.enumerated()), id: \.element) { index, feature in
                card(for: feature, at: index)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: Metrics.cardHeight + 28)
        .accessibilityHidden(true)
        .onAppear {
            withAnimation(.spring(duration: 0.9, bounce: 0.35).delay(reducesMotion ? 0 : 0.15)) {
                isFanned = true
            }
            isFloating = !reducesMotion
        }
    }

    private func card(for feature: OnboardingFeature, at index: Int) -> some View {
        let position = Double(index) - Double(features.count - 1) / 2
        return RoundedRectangle(cornerRadius: Metrics.cornerRadius)
            .fill(LinearGradient(colors: feature.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay {
                Image(systemName: feature.systemImage)
                    .font(.system(size: Metrics.symbolSize, weight: .semibold))
                    .foregroundStyle(.white)
                    .symbolEffect(.bounce, value: isFanned)
            }
            .overlay {
                RoundedRectangle(cornerRadius: Metrics.cornerRadius)
                    .strokeBorder(.white.opacity(0.35), lineWidth: 1)
            }
            .frame(width: Metrics.cardWidth, height: Metrics.cardHeight)
            .shadow(color: feature.gradientColors.last?.opacity(0.35) ?? .clear, radius: 10, y: 6)
            .offset(y: isFloating ? -3 : 3)
            .animation(
                isFloating
                    ? .easeInOut(duration: 2.2).repeatForever(autoreverses: true).delay(Double(index) * 0.3)
                    : nil,
                value: isFloating
            )
            .rotationEffect(.degrees(isFanned ? position * 9 : 0), anchor: .bottom)
            .offset(
                x: isFanned ? position * Metrics.spread : 0,
                y: isFanned ? abs(position) * 8 : 0
            )
            .zIndex(-abs(position))
    }

    private enum Metrics {
        #if os(macOS)
        static let cardWidth: CGFloat = 60
        static let cardHeight: CGFloat = 76
        static let cornerRadius: CGFloat = 14
        static let symbolSize: CGFloat = 24
        static let spread: CGFloat = 52
        #else
        static let cardWidth: CGFloat = 76
        static let cardHeight: CGFloat = 96
        static let cornerRadius: CGFloat = 18
        static let symbolSize: CGFloat = 30
        static let spread: CGFloat = 64
        #endif
    }
}
