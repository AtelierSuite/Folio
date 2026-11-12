import SwiftUI

struct OnboardingAlertsGraphic: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var isRippling = false

    var body: some View {
        ZStack {
            ForEach(0..<2, id: \.self) { index in
                Circle()
                    .strokeBorder(.orange, lineWidth: 3)
                    .scaleEffect(isRippling ? 1.05 : 0.5)
                    .opacity(isRippling ? 0 : 0.7)
                    .animation(
                        reducesMotion ? nil : .easeOut(duration: 2).repeatForever(autoreverses: false)
                            .delay(Double(index)),
                        value: isRippling
                    )
            }
            bell
        }
        .frame(width: 140, height: 140)
        .onAppear { isRippling = !reducesMotion }
    }

    @ViewBuilder private var bell: some View {
        let symbol = Image(systemName: "bell.fill")
            .font(.system(size: 64))
            .foregroundStyle(LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom))
        if reducesMotion {
            symbol
        } else {
            symbol.phaseAnimator([0.0, -16, 14, -10, 8, 0, 0]) { content, angle in
                content.rotationEffect(.degrees(angle), anchor: .top)
            } animation: { angle in
                angle == 0 ? .easeInOut(duration: 0.8) : .easeInOut(duration: 0.14)
            }
        }
    }
}
