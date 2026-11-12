import SwiftUI

struct OnboardingWeatherGraphic: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var isAnimating = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            sun
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            Image(systemName: "cloud.fill")
                .font(.system(size: 84))
                .foregroundStyle(LinearGradient(
                    colors: [.white, .cyan.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .shadow(color: .blue.opacity(0.25), radius: 8, y: 4)
                .offset(x: isAnimating ? 14 : 0)
                .animation(
                    reducesMotion ? nil : .easeInOut(duration: 3).repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
        .frame(width: 160, height: 140)
        .onAppear { isAnimating = !reducesMotion }
    }

    private var sun: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Capsule()
                    .fill(.orange)
                    .frame(width: 6, height: 16)
                    .offset(y: -46)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(
                reducesMotion ? nil : .linear(duration: 16).repeatForever(autoreverses: false),
                value: isAnimating
            )
            Circle()
                .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                .frame(width: 62, height: 62)
        }
        .frame(width: 110, height: 110)
    }
}
