import SwiftUI

struct OnboardingCarouselSleepScene: View {
    let isActive: Bool

    var body: some View {
        OnboardingCarouselLoop(
            isActive: isActive,
            count: 4,
            interval: .milliseconds(1100),
            hold: .seconds(2.4)
        ) { phase in
            ZStack(alignment: .topLeading) {
                OnboardingCarouselNightSky(hasRisen: phase >= 3, phase: phase)
                    .frame(width: 300, height: 250)
                    .clipShape(.rect(cornerRadius: 28, style: .continuous))
                    .offset(x: 10, y: 5)
                OnboardingCarouselSleepTimeline(phase: phase)
                    .frame(width: 272, height: 92)
                    .offset(x: 24, y: 148)
            }
            .frame(width: 320, height: 260, alignment: .topLeading)
        }
    }
}

private struct OnboardingCarouselNightSky: View {
    private static let stars: [CGPoint] = [
        CGPoint(x: 110, y: 30), CGPoint(x: 160, y: 58), CGPoint(x: 210, y: 24), CGPoint(x: 262, y: 66),
        CGPoint(x: 84, y: 88), CGPoint(x: 236, y: 110), CGPoint(x: 140, y: 112), CGPoint(x: 30, y: 120),
        CGPoint(x: 278, y: 30), CGPoint(x: 190, y: 92)
    ]

    let hasRisen: Bool
    let phase: Int

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: hasRisen
                    ? [Color(red: 0.38, green: 0.44, blue: 0.8), Color(red: 1, green: 0.68, blue: 0.46)]
                    : [Color(red: 0.06, green: 0.06, blue: 0.2), Color(red: 0.24, green: 0.2, blue: 0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
            ForEach(Self.stars.indices, id: \.self) { index in
                Circle()
                    .fill(.white)
                    .frame(width: index.isMultiple(of: 3) ? 4 : 2.5)
                    .opacity(hasRisen ? 0 : ((phase + index).isMultiple(of: 2) ? 0.95 : 0.45))
                    .offset(x: Self.stars[index].x, y: Self.stars[index].y)
            }
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 34))
                .foregroundStyle(.yellow.opacity(0.9))
                .offset(x: 30, y: hasRisen ? 70 : 24)
                .opacity(hasRisen ? 0 : 1)
            Circle()
                .fill(RadialGradient(colors: [.yellow, .orange], center: .center, startRadius: 6, endRadius: 40))
                .frame(width: 72, height: 72)
                .shadow(color: .orange.opacity(0.8), radius: 28)
                .offset(x: 196, y: hasRisen ? 54 : 230)
        }
        .animation(.easeInOut(duration: 1.6), value: hasRisen)
    }
}

private struct OnboardingCarouselSleepTimeline: View {
    private static let wakeFraction = 0.66

    let phase: Int

    private var sleepScale: Double {
        switch phase {
        case 0: 0
        case 1: 0.08
        default: 1
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Image(systemName: "moon.fill")
                        .foregroundStyle(phase > 0 ? AnyShapeStyle(Color.indigo) : AnyShapeStyle(.tertiary))
                    Image(systemName: "sunrise.fill")
                        .symbolRenderingMode(phase > 1 ? .multicolor : .monochrome)
                        .foregroundStyle(.tertiary)
                        .offset(x: proxy.size.width * Self.wakeFraction - 14)
                }
                .font(.system(size: 15, weight: .semibold))
            }
            .frame(height: 18)
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.primary.opacity(0.07))
                    Capsule()
                        .fill(LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing))
                        .frame(width: proxy.size.width * Self.wakeFraction)
                        .scaleEffect(x: sleepScale, anchor: .leading)
                        .animation(.easeInOut(duration: 1.3), value: sleepScale)
                    Capsule()
                        .fill(Color.orange.gradient)
                        .frame(width: proxy.size.width * 0.24)
                        .scaleEffect(phase > 3 ? 1 : 0.4, anchor: .leading)
                        .opacity(phase > 3 ? 1 : 0)
                        .offset(x: proxy.size.width * (Self.wakeFraction + 0.06))
                }
            }
            .frame(height: 16)
            HStack(spacing: 0) {
                ForEach(0..<9, id: \.self) { _ in
                    Capsule()
                        .fill(.secondary.opacity(0.4))
                        .frame(width: 2, height: 6)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .onboardingCarouselCard()
    }
}
