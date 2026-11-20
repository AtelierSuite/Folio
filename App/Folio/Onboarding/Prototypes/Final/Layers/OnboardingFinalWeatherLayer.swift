import SwiftUI

struct OnboardingFinalWeatherLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var hasDripped = false
    let geometry: OnboardingFinalTimelineGeometry
    let state: OnboardingFinalLayerState

    private static let symbols = [
        "moon.stars.fill", "moon.fill", "sunrise.fill", "sun.max.fill",
        "sun.max.fill", "cloud.sun.fill", "cloud.rain.fill", "cloud.moon.fill"
    ]
    private static let diameter: CGFloat = 24

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(Self.symbols.enumerated()), id: \.offset) { hour, symbol in
                let restingY = geometry.yPosition(Double(hour)) - Self.diameter / 2
                Image(systemName: symbol)
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 12))
                    .opacity(hasDripped ? state.contentOpacity : 0)
                    .frame(width: Self.diameter, height: Self.diameter)
                    .glassEffect(.regular.tint(Color.cyan.opacity(state.tintOpacity * 0.5)), in: .circle)
                    .offset(
                        x: geometry.gutterWidth - Self.diameter - 4,
                        y: hasDripped ? restingY : geometry.verticalInset
                    )
                    .animation(
                        reducesMotion ? nil : .spring(duration: 0.75, bounce: 0.3).delay(0.3 + Double(hour) * 0.11),
                        value: hasDripped
                    )
            }
        }
        .onAppear { hasDripped = true }
    }
}
