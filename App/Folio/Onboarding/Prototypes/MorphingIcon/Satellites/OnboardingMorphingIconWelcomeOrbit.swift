import SwiftUI

struct OnboardingMorphingIconWelcomeOrbit: View {
    let features: [OnboardingFeature]
    let highlightedFeature: OnboardingFeature?
    let unit: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(.secondary.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [3, 6]))
                .frame(width: 250 * unit, height: 250 * unit)
            ForEach(Array(features.enumerated()), id: \.element) { index, feature in
                bubble(for: feature)
                    .offset(OnboardingMorphingIconGeometry.offset(degrees: angle(at: index), radius: 125 * unit))
            }
        }
        .animation(.spring(duration: 0.5, bounce: 0.45), value: highlightedFeature)
    }

    private func angle(at index: Int) -> Double {
        -135 + Double(index) * 360 / Double(max(features.count, 1))
    }

    private func bubble(for feature: OnboardingFeature) -> some View {
        let isHighlighted = feature == highlightedFeature
        return Circle()
            .fill(LinearGradient(colors: feature.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay {
                Image(systemName: feature.systemImage)
                    .font(.system(size: 16 * unit, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 38 * unit, height: 38 * unit)
            .shadow(color: (feature.gradientColors.last ?? .black).opacity(0.35), radius: 8, y: 5)
            .scaleEffect(isHighlighted ? 1.25 : 0.85)
            .opacity(highlightedFeature == nil || isHighlighted ? 1 : 0.5)
    }
}
