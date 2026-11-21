import SwiftUI

struct OnboardingWeatherLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var sequence = OnboardingLaunchSequence()
    let geometry: OnboardingTimelineGeometry
    let source: CGPoint
    let state: OnboardingLayerState

    private static let symbols = [
        "moon.stars.fill", "moon.fill", "sunrise.fill", "sun.max.fill",
        "sun.max.fill", "cloud.sun.fill", "cloud.rain.fill", "cloud.moon.fill"
    ]
    private static let diameter: CGFloat = 24

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(Self.symbols.enumerated()), id: \.offset) { hour, symbol in
                let rank = Self.symbols.count - 1 - hour
                if sequence.isLaunched(rank) {
                    pill(symbol: symbol, hour: hour, isLanded: sequence.isLanded(rank))
                }
            }
        }
        .task(id: state == .declined) {
            await OnboardingLaunchSequence.follow(
                state,
                count: Self.symbols.count,
                sequence: $sequence,
                reducesMotion: reducesMotion
            )
        }
    }

    private func pill(symbol: String, hour: Int, isLanded: Bool) -> some View {
        let restingFrame = CGRect(
            x: geometry.gutterWidth - Self.diameter - 4,
            y: geometry.yPosition(Double(hour)) - Self.diameter / 2,
            width: Self.diameter,
            height: Self.diameter
        )
        return Image(systemName: symbol)
            .symbolRenderingMode(.multicolor)
            .font(.system(size: 12))
            .onboardingReveal(isLanded, opacity: state.contentOpacity)
            .frame(width: Self.diameter, height: Self.diameter)
            .glassEffect(.regular.tint(Color.cyan.opacity(state.tintOpacity * 0.5)), in: .circle)
            .onboardingFlight(
                from: OnboardingTimelineGeometry.seedFrame(at: source),
                to: restingFrame,
                isLanded: isLanded
            )
    }
}
