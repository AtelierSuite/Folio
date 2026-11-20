import SwiftUI

struct OnboardingColorFieldsWeatherHero: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    private static let forecast = ["sun.max.fill", "cloud.sun.fill", "cloud.fill", "cloud.rain.fill", "cloud.sun.fill"]
    private static let eventWidths: [CGFloat] = [30, 22, 34, 26, 30]

    var body: some View {
        OnboardingSequencePlayer(
            count: Self.forecast.count,
            interval: .milliseconds(450),
            hold: .seconds(2.4)
        ) { shownCount in
            VStack(spacing: 24) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "cloud.sun.rain.fill")
                        .symbolEffect(.variableColor.iterative.reversing, isActive: !reducesMotion)
                        .onboardingColorFieldsSymbol()
                    OnboardingColorFieldsLocationPin()
                        .offset(x: 18, y: -6)
                }
                forecastRow(shownCount: shownCount)
            }
        }
    }

    private func forecastRow(shownCount: Int) -> some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(Array(Self.forecast.enumerated()), id: \.offset) { index, symbol in
                let isShown = index < shownCount
                VStack(spacing: 8) {
                    Image(systemName: symbol)
                        .font(.system(size: 16, weight: .semibold))
                        .opacity(isShown ? 1 : 0)
                        .scaleEffect(isShown ? 1 : 0.4)
                        .offset(y: isShown ? 0 : 8)
                    Capsule()
                        .fill(.white.opacity(0.85))
                        .frame(width: Self.eventWidths[index], height: 8)
                }
            }
        }
    }
}

private struct OnboardingColorFieldsLocationPin: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion

    var body: some View {
        Image(systemName: "location.fill")
            .font(.system(size: 18, weight: .bold))
            .padding(10)
            .background(.white.opacity(0.22), in: .circle)
            .background {
                Circle()
                    .strokeBorder(.white.opacity(0.6), lineWidth: 1.5)
                    .phaseAnimator([false, true]) { content, isExpanded in
                        content
                            .scaleEffect(isExpanded && !reducesMotion ? 1.9 : 1)
                            .opacity(isExpanded && !reducesMotion ? 0 : 0.8)
                    } animation: { isExpanded in
                        isExpanded ? .easeOut(duration: 1.6) : .linear(duration: 0.01).delay(0.6)
                    }
            }
    }
}
