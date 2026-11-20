import SwiftUI

struct OnboardingSleepGraphic: View {
    private static let stages: [(level: Int, length: Double)] = [
        (1, 0.8), (2, 1.2), (3, 1), (2, 0.7), (0, 0.6), (1, 1), (3, 0.8), (2, 1.1), (1, 0.7), (0, 0.4)
    ]

    var body: some View {
        OnboardingGraphicCard(tint: .indigo, background: Self.nightSky) {
            OnboardingSequencePlayer(count: Self.stages.count + 1, interval: .milliseconds(180)) { shownCount in
                VStack(spacing: 10) {
                    OnboardingNightSky(isMorning: shownCount > Self.stages.count)
                    OnboardingHypnogram(stages: Self.stages, shownCount: shownCount)
                }
                .background {
                    Self.sunrise
                        .padding(-24)
                        .opacity(shownCount > Self.stages.count ? 1 : 0)
                        .animation(.easeInOut(duration: 1.2), value: shownCount > Self.stages.count)
                }
            }
        }
        .environment(\.colorScheme, .dark)
    }

    private static var sunrise: some View {
        LinearGradient(colors: [.clear, .orange.opacity(0.35)], startPoint: .center, endPoint: .bottomTrailing)
            .allowsHitTesting(false)
    }

    private static var nightSky: AnyShapeStyle {
        AnyShapeStyle(LinearGradient(
            colors: [Color(red: 0.08, green: 0.07, blue: 0.24), Color(red: 0.18, green: 0.16, blue: 0.42)],
            startPoint: .top,
            endPoint: .bottom
        ))
    }
}

private struct OnboardingNightSky: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var isTwinkling = false
    let isMorning: Bool
    private static let stars: [(offset: CGSize, size: CGFloat)] = [
        (CGSize(width: 70, height: -14), 16), (CGSize(width: 120, height: 12), 10),
        (CGSize(width: 180, height: -8), 13), (CGSize(width: 40, height: 22), 9)
    ]

    var body: some View {
        ZStack(alignment: .leading) {
            Image(systemName: "moon.stars.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.yellow, LinearGradient(colors: [.white, .teal], startPoint: .top, endPoint: .bottom))
                .font(.system(size: 46))
                .opacity(isMorning ? 0.3 : 1)
            ForEach(Array(Self.stars.enumerated()), id: \.offset) { index, star in
                Image(systemName: "sparkle")
                    .font(.system(size: star.size))
                    .foregroundStyle(.yellow)
                    .scaleEffect(isTwinkling ? 1 : 0.5)
                    .opacity(isMorning ? 0 : (isTwinkling ? 1 : 0.35))
                    .animation(
                        reducesMotion ? nil : .easeInOut(duration: 1.1).repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.35),
                        value: isTwinkling
                    )
                    .offset(star.offset)
            }
            Image(systemName: "sun.horizon.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.yellow, .orange)
                .font(.system(size: 38))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .offset(y: isMorning ? 0 : 20)
                .opacity(isMorning ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .onAppear { isTwinkling = !reducesMotion }
    }
}

private struct OnboardingHypnogram: View {
    private static let levelCount = 4
    private static let colors: [Color] = [.orange, .cyan, .blue, .indigo]
    let stages: [(level: Int, length: Double)]
    let shownCount: Int

    var body: some View {
        GeometryReader { proxy in
            let totalLength = stages.reduce(0) { $0 + $1.length }
            let unitWidth = proxy.size.width / totalLength
            let rowHeight = proxy.size.height / CGFloat(Self.levelCount)
            ZStack(alignment: .topLeading) {
                ForEach(0..<Self.levelCount, id: \.self) { level in
                    Rectangle()
                        .fill(.white.opacity(0.08))
                        .frame(height: 1)
                        .offset(y: rowHeight * (CGFloat(level) + 0.5))
                }
                ForEach(Array(stages.enumerated()), id: \.offset) { index, stage in
                    let start = stages.prefix(index).reduce(0) { $0 + $1.length }
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Self.colors[stage.level].gradient)
                        .frame(width: unitWidth * stage.length - 2, height: rowHeight - 6)
                        .scaleEffect(x: index < shownCount ? 1 : 0, anchor: .leading)
                        .opacity(index < shownCount ? 1 : 0)
                        .offset(x: unitWidth * start, y: rowHeight * CGFloat(stage.level) + 3)
                }
            }
        }
        .frame(height: 76)
    }
}
