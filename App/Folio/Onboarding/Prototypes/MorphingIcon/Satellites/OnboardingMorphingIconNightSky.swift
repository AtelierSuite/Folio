import SwiftUI

struct OnboardingMorphingIconNightSky: View {
    let unit: CGFloat
    @Environment(\.accessibilityReduceMotion) private var reducesMotion

    private static let starColor = Color(red: 1.0, green: 0.93, blue: 0.7)
    private static let starCount = 14

    var body: some View {
        TimelineView(.animation(paused: reducesMotion)) { timeline in
            let time = reducesMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                halo
                ForEach(0..<Self.starCount, id: \.self) { index in
                    star(index: index, time: time)
                }
                crescent(time: time)
            }
        }
    }

    private var halo: some View {
        Circle()
            .fill(RadialGradient(
                colors: [Color(red: 0.12, green: 0.13, blue: 0.36).opacity(0.55), .clear],
                center: .center,
                startRadius: 40 * unit,
                endRadius: 170 * unit
            ))
            .frame(width: 340 * unit, height: 340 * unit)
    }

    private func star(index: Int, time: Double) -> some View {
        let angle = Double(index) * 137.5
        let radius = (96 + CGFloat((index * 37) % 56)) * unit
        let size = (index % 3 == 0 ? 14 : 6) * unit
        let speed = 0.8 + Double(index % 4) * 0.35
        let twinkle = reducesMotion ? 1 : 0.25 + 0.75 * abs(sin(time * speed + Double(index)))
        return Group {
            if index % 3 == 0 {
                Image(systemName: "sparkle")
                    .font(.system(size: size))
            } else {
                Circle().frame(width: size, height: size)
            }
        }
        .foregroundStyle(Self.starColor)
        .shadow(color: Self.starColor.opacity(0.8), radius: 4)
        .opacity(twinkle)
        .scaleEffect(0.7 + 0.3 * twinkle)
        .offset(OnboardingMorphingIconGeometry.offset(degrees: angle, radius: radius))
    }

    private func crescent(time: Double) -> some View {
        let angle = -90 + 52 * sin(time * 0.45)
        return Image(systemName: "moon.fill")
            .font(.system(size: 34 * unit))
            .foregroundStyle(LinearGradient(colors: [Self.starColor, .yellow], startPoint: .top, endPoint: .bottom))
            .shadow(color: .yellow.opacity(0.6), radius: 10)
            .rotationEffect(.degrees(angle + 90 - 20))
            .offset(OnboardingMorphingIconGeometry.offset(degrees: angle, radius: 116 * unit))
    }
}
