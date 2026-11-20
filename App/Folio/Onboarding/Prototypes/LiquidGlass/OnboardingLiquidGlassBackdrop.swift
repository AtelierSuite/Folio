import SwiftUI

struct OnboardingLiquidGlassBackdrop: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @Environment(\.colorScheme) private var colorScheme
    let colors: [Color]

    var body: some View {
        TimelineView(.animation(paused: reducesMotion)) { timeline in
            let time = reducesMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            GeometryReader { proxy in
                ZStack {
                    ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                        Circle()
                            .fill(color)
                            .frame(width: proxy.size.width * 0.75, height: proxy.size.width * 0.75)
                            .position(blobCenter(index: index, time: time, in: proxy.size))
                    }
                }
                .blur(radius: 60)
                .opacity(colorScheme == .dark ? 0.55 : 0.45)
            }
        }
        .animation(.easeInOut(duration: 1.2), value: colors)
        .mask {
            LinearGradient(
                stops: [
                    .init(color: .black, location: 0),
                    .init(color: .black, location: 0.25),
                    .init(color: .clear, location: 0.62)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private func blobCenter(index: Int, time: TimeInterval, in size: CGSize) -> CGPoint {
        let speed = 0.18 + Double(index) * 0.05
        let offset = Double(index) * 1.7
        let horizontal = 0.5 + 0.38 * sin(time * speed + offset)
        let vertical = 0.22 + 0.14 * cos(time * speed * 1.3 + offset * 2)
        return CGPoint(x: size.width * horizontal, y: size.height * vertical)
    }
}
