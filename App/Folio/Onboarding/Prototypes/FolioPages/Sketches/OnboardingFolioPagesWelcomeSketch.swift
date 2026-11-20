import SwiftUI

struct OnboardingFolioPagesWelcomeSketch: View {
    let features: [OnboardingFeature]
    let ink: OnboardingFolioPagesInk
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let palette = OnboardingFolioPagesPalette(colorScheme: colorScheme)
        GeometryReader { proxy in
            ForEach(Array(features.enumerated()), id: \.element) { index, feature in
                let center = position(of: index)
                let start = Double(index) * 0.35
                Circle()
                    .onboardingFolioPagesInked(ink.stroke(start, 0.6), color: palette.ink.opacity(0.7), lineWidth: 1.8)
                    .rotationEffect(.degrees(-90 + Double(index) * 40))
                    .onboardingFolioPagesPlaced(
                        in: proxy.size, horizontal: center.x, vertical: center.y, side: 0.36
                    )
                stamp(for: feature, progress: ink.stroke(start + 0.45, 0.35))
                    .onboardingFolioPagesPlaced(
                        in: proxy.size, horizontal: center.x, vertical: center.y, side: 0.36
                    )
                OnboardingFolioPagesScribble(
                    progress: ink.stroke(start + 0.6, 0.4),
                    color: palette.ink.opacity(0.3),
                    thickness: 4
                )
                .onboardingFolioPagesPlaced(
                    in: proxy.size, horizontal: center.x, vertical: center.y + 0.24, width: 0.26, height: 0.03
                )
            }
        }
    }

    private func stamp(for feature: OnboardingFeature, progress: CGFloat) -> some View {
        Image(systemName: feature.systemImage)
            .font(.system(size: 28, weight: .semibold))
            .foregroundStyle(LinearGradient(
                colors: feature.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .scaleEffect(1.5 - 0.5 * progress)
            .opacity(progress)
    }

    private func position(of index: Int) -> CGPoint {
        let column = index % 2
        let row = index / 2
        let isLoneLast = index == features.count - 1 && features.count.isMultiple(of: 2) == false
        let horizontal = isLoneLast ? 0.5 : 0.25 + CGFloat(column) * 0.5
        return CGPoint(x: horizontal, y: 0.22 + CGFloat(row) * 0.5)
    }
}
