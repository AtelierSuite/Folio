import SwiftUI

struct OnboardingLivingTimelineWeatherLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var hasForecast = false
    let geometry: OnboardingLivingTimelineGeometry
    let state: OnboardingLivingTimelineLayerState

    private static let symbols = [
        "moon.stars.fill", "moon.fill", "sunrise.fill", "sun.max.fill",
        "sun.max.fill", "cloud.sun.fill", "cloud.rain.fill", "cloud.moon.fill"
    ]

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(Self.symbols.enumerated()), id: \.offset) { hour, symbol in
                Image(systemName: symbol)
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 12))
                    .frame(width: 18, height: 18)
                    .scaleEffect(hasForecast ? 1 : 0.2)
                    .opacity(hasForecast ? 1 : 0)
                    .offset(x: geometry.gutterWidth - 21, y: geometry.yPosition(Double(hour)) - 9)
                    .animation(
                        reducesMotion ? nil : .spring(duration: 0.5, bounce: 0.5).delay(0.35 + Double(hour) * 0.09),
                        value: hasForecast
                    )
            }
        }
        .onAppear { hasForecast = true }
    }
}

struct OnboardingLivingTimelineWeatherTint: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var isTinted = false
    let geometry: OnboardingLivingTimelineGeometry
    let state: OnboardingLivingTimelineLayerState

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 10)
        LinearGradient(
            colors: [.indigo, .blue, .cyan, .yellow, .orange, .orange, .teal, .indigo],
            startPoint: .top,
            endPoint: .bottom
        )
        .opacity(0.22)
        .clipShape(shape)
        .livingTimelineOutline(state == .current, shape: shape, color: .cyan)
        .frame(width: geometry.gutterWidth - 8, height: geometry.size.height - 12)
        .scaleEffect(y: isTinted ? 1 : 0, anchor: .top)
        .offset(x: 4, y: 6)
        .onAppear {
            withAnimation(reducesMotion ? nil : .easeOut(duration: 1.2)) { isTinted = true }
        }
    }
}
