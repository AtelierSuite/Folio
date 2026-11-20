import SwiftUI

struct OnboardingJourneyWeatherHero: View {
    private static let temperatures: [Double] = [0.3, 0.45, 0.7, 0.92, 0.8, 0.55]
    private static let glowGradient = LinearGradient(
        colors: [.yellow, .orange],
        startPoint: .top,
        endPoint: .bottom
    )
    private let tint = OnboardingJourneyPalette.tint(for: .weather)

    var body: some View {
        OnboardingSequencePlayer(
            count: Self.temperatures.count,
            interval: .milliseconds(480),
            hold: .seconds(1.8)
        ) { shownCount in
            VStack(spacing: 0) {
                sunArc(progress: shownCount == 0 ? 0 : (Double(shownCount) - 0.5) / Double(Self.temperatures.count))
                Capsule()
                    .fill(tint.opacity(0.35))
                    .frame(height: 2)
                    .padding(.bottom, 8)
                HStack(alignment: .bottom, spacing: Metrics.barSpacing) {
                    ForEach(Array(Self.temperatures.enumerated()), id: \.offset) { index, temperature in
                        bar(temperature: temperature, isShown: index < shownCount, isNow: index == shownCount - 1)
                    }
                }
                .frame(height: Metrics.barMaxHeight, alignment: .bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }

    private func sunArc(progress: Double) -> some View {
        ZStack {
            Circle()
                .trim(from: 0.5, to: 1)
                .stroke(.secondary.opacity(0.35), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [3, 6]))
            Circle()
                .trim(from: 0.5, to: 0.5 + progress / 2)
                .stroke(Color.orange.opacity(0.7), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            Color.clear
                .overlay(alignment: .leading) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: Metrics.sunSize))
                        .foregroundStyle(Self.glowGradient)
                        .shadow(color: .orange.opacity(0.6), radius: 8)
                        .frame(width: Metrics.sunSize * 1.4, height: Metrics.sunSize * 1.4)
                        .rotationEffect(.degrees(-180 * progress))
                        .offset(x: -Metrics.sunSize * 0.7)
                }
                .rotationEffect(.degrees(180 * progress))
        }
        .frame(width: Metrics.arcRadius * 2, height: Metrics.arcRadius * 2)
        .frame(height: Metrics.arcRadius + 4, alignment: .top)
    }

    private func bar(temperature: Double, isShown: Bool, isNow: Bool) -> some View {
        let isWarm = temperature > 0.65
        return RoundedRectangle(cornerRadius: 6)
            .fill(LinearGradient(
                colors: isWarm ? [.orange, .yellow] : [.blue, .cyan],
                startPoint: .top,
                endPoint: .bottom
            ))
            .frame(width: Metrics.barWidth, height: 10 + temperature * (Metrics.barMaxHeight - 10))
            .scaleEffect(y: isShown ? 1 : 0.08, anchor: .bottom)
            .opacity(isShown ? 1 : 0.3)
            .overlay {
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(.primary.opacity(isNow ? 0.6 : 0), lineWidth: 2)
                    .scaleEffect(y: isShown ? 1 : 0.08, anchor: .bottom)
            }
    }

    private enum Metrics {
        #if os(macOS)
        static let arcRadius: CGFloat = 66
        static let sunSize: CGFloat = 22
        static let barWidth: CGFloat = 18
        static let barSpacing: CGFloat = 12
        static let barMaxHeight: CGFloat = 48
        #else
        static let arcRadius: CGFloat = 82
        static let sunSize: CGFloat = 28
        static let barWidth: CGFloat = 22
        static let barSpacing: CGFloat = 16
        static let barMaxHeight: CGFloat = 62
        #endif
    }
}
