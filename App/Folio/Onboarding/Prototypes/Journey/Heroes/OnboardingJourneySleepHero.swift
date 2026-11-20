import SwiftUI

struct OnboardingJourneySleepHero: View {
    private static let stars: [CGPoint] = [
        CGPoint(x: 0.15, y: 0.2), CGPoint(x: 0.72, y: 0.15), CGPoint(x: 0.5, y: 0.38),
        CGPoint(x: 0.86, y: 0.5), CGPoint(x: 0.3, y: 0.58)
    ]
    private static let glowGradient = LinearGradient(
        colors: [.yellow, .orange],
        startPoint: .top,
        endPoint: .bottom
    )
    private let tint = OnboardingJourneyPalette.tint(for: .sleep)

    var body: some View {
        OnboardingJourneyProgressLoop(duration: 3.2, hold: .seconds(1.4)) { progress in
            HStack(spacing: Metrics.spacing) {
                sky(progress: progress)
                ring(progress: progress)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func sky(progress: Double) -> some View {
        let angle = -40 + 135 * progress
        return ZStack {
            LinearGradient(
                colors: [tint.opacity(0.45), Color.purple.opacity(0.12)],
                startPoint: .top,
                endPoint: .bottom
            )
            GeometryReader { proxy in
                ForEach(Array(Self.stars.enumerated()), id: \.offset) { index, star in
                    Circle()
                        .fill(.white)
                        .frame(width: index.isMultiple(of: 2) ? 3 : 2)
                        .opacity(0.9 - progress * 0.6)
                        .position(x: star.x * proxy.size.width, y: star.y * proxy.size.height)
                }
                Color.clear
                    .frame(width: Metrics.moonOrbit * 2, height: Metrics.moonOrbit * 2)
                    .overlay(alignment: .top) {
                        Image(systemName: "moon.fill")
                            .font(.system(size: Metrics.moonSize))
                            .foregroundStyle(Self.glowGradient)
                            .shadow(color: .yellow.opacity(0.5), radius: 8)
                            .frame(width: Metrics.moonSize * 1.4, height: Metrics.moonSize * 1.4)
                            .rotationEffect(.degrees(-angle))
                            .offset(y: -Metrics.moonSize * 0.7)
                    }
                    .rotationEffect(.degrees(angle))
                    .position(x: proxy.size.width / 2, y: proxy.size.height)
            }
            VStack {
                Spacer()
                Rectangle()
                    .fill(tint.opacity(0.5))
                    .frame(height: Metrics.horizonHeight)
            }
        }
        .frame(width: Metrics.skyWidth, height: Metrics.skyHeight)
        .clipShape(.rect(cornerRadius: 16))
    }

    private func ring(progress: Double) -> some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.15), lineWidth: Metrics.ringWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    OnboardingJourneyPalette.gradient(for: .sleep),
                    style: StrokeStyle(lineWidth: Metrics.ringWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Image(systemName: "bed.double.fill")
                .font(.system(size: Metrics.bedSize, weight: .semibold))
                .foregroundStyle(tint)
        }
        .frame(width: Metrics.ringDiameter, height: Metrics.ringDiameter)
    }

    private enum Metrics {
        #if os(macOS)
        static let spacing: CGFloat = 24
        static let skyWidth: CGFloat = 140
        static let skyHeight: CGFloat = 112
        static let moonSize: CGFloat = 24
        static let moonOrbit: CGFloat = 80
        static let horizonHeight: CGFloat = 14
        static let ringDiameter: CGFloat = 92
        static let ringWidth: CGFloat = 12
        static let bedSize: CGFloat = 24
        #else
        static let spacing: CGFloat = 28
        static let skyWidth: CGFloat = 160
        static let skyHeight: CGFloat = 140
        static let moonSize: CGFloat = 30
        static let moonOrbit: CGFloat = 100
        static let horizonHeight: CGFloat = 18
        static let ringDiameter: CGFloat = 116
        static let ringWidth: CGFloat = 15
        static let bedSize: CGFloat = 30
        #endif
    }
}
