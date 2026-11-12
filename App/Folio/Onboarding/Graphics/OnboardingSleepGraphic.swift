import SwiftUI

struct OnboardingSleepGraphic: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var isTwinkling = false
    private static let stars: [(offset: CGSize, size: CGFloat)] = [
        (CGSize(width: 44, height: -44), 26), (CGSize(width: 62, height: 6), 16), (CGSize(width: 10, height: -58), 14)
    ]

    var body: some View {
        ZStack {
            Image(systemName: "moon.fill")
                .font(.system(size: 84))
                .foregroundStyle(LinearGradient(
                    colors: [.teal, .indigo],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .offset(x: -14, y: 8)
            ForEach(Array(Self.stars.enumerated()), id: \.offset) { index, star in
                Image(systemName: "sparkle")
                    .font(.system(size: star.size))
                    .foregroundStyle(.yellow)
                    .scaleEffect(isTwinkling ? 1 : 0.5)
                    .opacity(isTwinkling ? 1 : 0.35)
                    .animation(
                        reducesMotion ? nil : .easeInOut(duration: 1.1).repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.4),
                        value: isTwinkling
                    )
                    .offset(star.offset)
            }
        }
        .frame(width: 160, height: 140)
        .onAppear { isTwinkling = true }
    }
}
