import SwiftUI

struct OnboardingCarouselWeatherScene: View {
    let isActive: Bool

    var body: some View {
        OnboardingCarouselLoop(
            isActive: isActive,
            count: 7,
            interval: .milliseconds(480),
            hold: .seconds(2.4)
        ) { phase in
            ZStack(alignment: .topLeading) {
                OnboardingCarouselSky(phase: phase)
                    .frame(width: 300, height: 250)
                    .clipShape(.rect(cornerRadius: 28, style: .continuous))
                    .offset(x: 10, y: 5)
                OnboardingCarouselPinDrop(isDropped: phase > 0)
                    .frame(width: 120, height: 90)
                    .offset(x: 100, y: 34)
                OnboardingCarouselHourColumns(shownCount: max(phase - 2, 0))
                    .frame(width: 270, height: 112)
                    .offset(x: 25, y: 132)
            }
            .frame(width: 320, height: 260, alignment: .topLeading)
        }
    }
}

private struct OnboardingCarouselSky: View {
    let phase: Int

    private var isDaytime: Bool { phase >= 2 }

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: isDaytime
                    ? [Color(red: 0.3, green: 0.62, blue: 0.98), Color(red: 0.62, green: 0.84, blue: 1)]
                    : [Color(red: 0.2, green: 0.24, blue: 0.48), Color(red: 0.58, green: 0.52, blue: 0.76)],
                startPoint: .top,
                endPoint: .bottom
            )
            Circle()
                .fill(RadialGradient(colors: [.yellow, .orange], center: .center, startRadius: 4, endRadius: 30))
                .frame(width: 52, height: 52)
                .shadow(color: .yellow.opacity(0.7), radius: 20)
                .offset(x: isDaytime ? 222 : 40, y: isDaytime ? 22 : 170)
                .animation(.easeInOut(duration: 1.6), value: isDaytime)
            cloud(size: 46, opacity: 0.95)
                .offset(x: 18 + Double(phase) * 9, y: 26)
            cloud(size: 34, opacity: 0.75)
                .offset(x: 196 - Double(phase) * 6, y: 84)
        }
        .animation(.easeInOut(duration: 1.2), value: phase)
    }

    private func cloud(size: CGFloat, opacity: Double) -> some View {
        Image(systemName: "cloud.fill")
            .font(.system(size: size))
            .foregroundStyle(.white.opacity(opacity))
    }
}

private struct OnboardingCarouselPinDrop: View {
    let isDropped: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            Ellipse()
                .fill(.black.opacity(0.18))
                .frame(width: isDropped ? 34 : 10, height: 9)
            OnboardingCarouselPin()
                .padding(.bottom, 4)
                .offset(y: isDropped ? 0 : -150)
                .opacity(isDropped ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

private struct OnboardingCarouselHourColumns: View {
    private static let symbols = ["sun.max.fill", "cloud.sun.fill", "cloud.rain.fill", "cloud.sun.fill", "sun.max.fill"]
    private static let temperatures: [CGFloat] = [28, 36, 22, 32, 42]

    let shownCount: Int

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(Self.symbols.indices, id: \.self) { index in
                let isShown = index < shownCount
                VStack(spacing: 8) {
                    Image(systemName: Self.symbols[index])
                        .symbolRenderingMode(.multicolor)
                        .font(.system(size: 20))
                    Capsule()
                        .fill(LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom))
                        .frame(width: 8, height: Self.temperatures[index])
                    Capsule()
                        .fill(.secondary.opacity(0.4))
                        .frame(width: 18, height: 4)
                }
                .padding(.vertical, 10)
                .frame(width: 42)
                .background(.blue.opacity(0.12), in: .capsule)
                .scaleEffect(isShown ? 1 : 0.6, anchor: .bottom)
                .opacity(isShown ? 1 : 0)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .onboardingCarouselCard()
    }
}

private struct OnboardingCarouselPin: View {
    var body: some View {
        VStack(spacing: -6) {
            Circle()
                .fill(LinearGradient(colors: [.red.opacity(0.85), .red], startPoint: .top, endPoint: .bottom))
                .frame(width: 34, height: 34)
                .overlay {
                    Circle()
                        .fill(.white)
                        .frame(width: 12, height: 12)
                }
            OnboardingCarouselPinTip()
                .fill(.red)
                .frame(width: 16, height: 16)
        }
        .shadow(color: .black.opacity(0.22), radius: 6, y: 4)
    }
}

nonisolated struct OnboardingCarouselPinTip: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}
