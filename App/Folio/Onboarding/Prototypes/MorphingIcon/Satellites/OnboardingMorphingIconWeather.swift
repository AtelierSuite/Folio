import SwiftUI

struct OnboardingMorphingIconWeatherSky: View {
    let unit: CGFloat
    @Environment(\.accessibilityReduceMotion) private var reducesMotion

    private static let dropColumns: [CGFloat] = [-98, -90, -82, -74, -66, -58, -50, -42, -94, -78, -62]

    var body: some View {
        TimelineView(.animation(paused: reducesMotion)) { timeline in
            let time = reducesMotion ? 0.35 : timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                sun(time: time)
                ForEach(Self.dropColumns.indices, id: \.self) { index in
                    drop(index: index, time: time)
                }
            }
        }
    }

    private func sun(time: Double) -> some View {
        Image(systemName: "sun.max.fill")
            .font(.system(size: 66 * unit))
            .foregroundStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
            .rotationEffect(.degrees(time * 14))
            .shadow(color: .orange.opacity(0.5), radius: 16)
            .offset(x: 62 * unit, y: -62 * unit)
    }

    private func drop(index: Int, time: Double) -> some View {
        let cycle = (time * 1.1 + Double(index) * 0.37).truncatingRemainder(dividingBy: 1)
        return Capsule()
            .fill(LinearGradient(
                colors: [Color.blue.opacity(0.2), Color(red: 0.2, green: 0.55, blue: 1.0)],
                startPoint: .top,
                endPoint: .bottom
            ))
            .frame(width: 3 * unit, height: 13 * unit)
            .rotationEffect(.degrees(12))
            .offset(x: Self.dropColumns[index] * unit - cycle * 10 * unit, y: (40 + cycle * 100) * unit)
            .opacity(1 - pow(cycle, 3))
    }
}

struct OnboardingMorphingIconWeatherClouds: View {
    let unit: CGFloat
    @Environment(\.accessibilityReduceMotion) private var reducesMotion

    var body: some View {
        TimelineView(.animation(paused: reducesMotion)) { timeline in
            let time = reducesMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                cloud(size: 58)
                    .offset(x: (-72 + sin(time * 0.6) * 10) * unit, y: 30 * unit)
                cloud(size: 40)
                    .offset(x: (88 + sin(time * 0.5 + 2) * 12) * unit, y: -18 * unit)
            }
        }
    }

    private func cloud(size: CGFloat) -> some View {
        Image(systemName: "cloud.fill")
            .font(.system(size: size * unit))
            .foregroundStyle(LinearGradient(
                colors: [.white, Color(white: 0.86)], startPoint: .top, endPoint: .bottom
            ))
            .shadow(color: .black.opacity(0.16), radius: 8, y: 4)
    }
}
