import SwiftUI

struct OnboardingMorphingIconCalendarTrack: View {
    let unit: CGFloat

    var body: some View {
        Ellipse()
            .stroke(.secondary.opacity(0.22), style: StrokeStyle(lineWidth: 1, dash: [3, 6]))
            .frame(width: 236 * unit, height: 236 * unit * 0.72)
    }
}

struct OnboardingMorphingIconCalendarOrbit: View {
    let beat: Int
    let unit: CGFloat
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var angle: Double = -60
    @State private var dockProgress: Double = 0

    private static let eventColors: [Color] = [.blue, .orange, .purple]
    private static let dockPoints: [CGSize] = [
        CGSize(width: 100, height: -42), CGSize(width: -100, height: 0), CGSize(width: 100, height: 42)
    ]

    var body: some View {
        ZStack {
            ForEach(Self.eventColors.indices, id: \.self) { index in
                pill(color: Self.eventColors[index])
                    .modifier(OnboardingMorphingIconOrbitPlacement(
                        angle: angle + Double(index) * 120,
                        dockProgress: dockProgress,
                        radius: 118 * unit,
                        dock: CGSize(
                            width: Self.dockPoints[index].width * unit,
                            height: Self.dockPoints[index].height * unit
                        )
                    ))
            }
        }
        .onAppear {
            if reducesMotion {
                dockProgress = 1
            } else {
                withAnimation(.easeInOut(duration: 1.1)) { angle += 60 }
            }
        }
        .onChange(of: beat) { _, newBeat in
            switch newBeat % 4 {
            case 0:
                withAnimation(.spring(duration: 0.8, bounce: 0.2)) {
                    dockProgress = 0
                    angle += 50
                }
            case 3:
                withAnimation(.spring(duration: 0.7, bounce: 0.4)) { dockProgress = 1 }
            default:
                withAnimation(.easeInOut(duration: 1.2)) { angle += 70 }
            }
        }
    }

    private func pill(color: Color) -> some View {
        HStack(spacing: 7 * unit) {
            RoundedRectangle(cornerRadius: 2 * unit)
                .fill(color)
                .frame(width: 4 * unit, height: 22 * unit)
            VStack(alignment: .leading, spacing: 4 * unit) {
                Capsule().fill(.primary.opacity(0.7)).frame(width: 46 * unit, height: 5 * unit)
                Capsule().fill(.secondary.opacity(0.45)).frame(width: 28 * unit, height: 4 * unit)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8 * unit)
        .frame(width: 96 * unit, height: 36 * unit)
        .background(color.opacity(0.14), in: RoundedRectangle(cornerRadius: 10 * unit, style: .continuous))
        .background(.background, in: RoundedRectangle(cornerRadius: 10 * unit, style: .continuous))
        .shadow(color: .black.opacity(0.14), radius: 8, y: 4)
    }
}
