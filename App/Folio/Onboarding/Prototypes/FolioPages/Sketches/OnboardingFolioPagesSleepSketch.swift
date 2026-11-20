import SwiftUI

struct OnboardingFolioPagesSleepSketch: View {
    let ink: OnboardingFolioPagesInk
    @Environment(\.colorScheme) private var colorScheme

    private static let wakeX: CGFloat = 0.68
    private let sleepPoints = [
        CGPoint(x: 0, y: 0.05), CGPoint(x: 0.12, y: 0.7), CGPoint(x: 0.24, y: 0.95),
        CGPoint(x: 0.38, y: 0.45), CGPoint(x: 0.5, y: 0.85), CGPoint(x: 0.64, y: 0.35),
        CGPoint(x: 0.78, y: 0.6), CGPoint(x: 0.9, y: 0.15), CGPoint(x: 1, y: 0)
    ]
    private let stars = [CGPoint(x: 0.5, y: 0.1), CGPoint(x: 0.86, y: 0.16), CGPoint(x: 0.56, y: 0.32)]

    var body: some View {
        let palette = OnboardingFolioPagesPalette(colorScheme: colorScheme)
        GeometryReader { proxy in
            let size = proxy.size
            OnboardingFolioPagesMoon()
                .fill(Color.indigo.opacity(0.25 * ink.stroke(0.9, 0.4)))
                .onboardingFolioPagesPlaced(in: size, horizontal: 0.2, vertical: 0.2, side: 0.32)
            OnboardingFolioPagesMoon()
                .onboardingFolioPagesInked(ink.stroke(0.2, 0.8), color: .indigo, lineWidth: 2.2)
                .onboardingFolioPagesPlaced(in: size, horizontal: 0.2, vertical: 0.2, side: 0.32)
            ForEach(stars.indices, id: \.self) { index in
                Image(systemName: "sparkle")
                    .font(.system(size: 13 - CGFloat(index) * 2))
                    .foregroundStyle(Color.indigo.opacity(0.8))
                    .scaleEffect(ink.stroke(0.9 + Double(index) * 0.2, 0.3))
                    .position(x: size.width * stars[index].x, y: size.height * stars[index].y)
            }
            OnboardingFolioPagesCurve(points: sleepPoints)
                .onboardingFolioPagesInked(ink.stroke(1.3, 1.5), color: .teal, lineWidth: 2.6)
                .onboardingFolioPagesPlaced(
                    in: size, horizontal: Self.wakeX / 2, vertical: 0.72, width: Self.wakeX, height: 0.32
                )
            OnboardingFolioPagesCurve(points: [CGPoint(x: 0.5, y: 0), CGPoint(x: 0.5, y: 1)])
                .onboardingFolioPagesInked(
                    ink.stroke(2.7, 0.4), color: palette.ink.opacity(0.5), lineWidth: 1.4, dash: [3, 4]
                )
                .onboardingFolioPagesPlaced(
                    in: size, horizontal: Self.wakeX + 0.02, vertical: 0.7, width: 0.02, height: 0.5
                )
            morningPlan(palette: palette)
                .onboardingFolioPagesPlaced(in: size, horizontal: 0.86, vertical: 0.7, width: 0.26, height: 0.34)
        }
    }

    private func morningPlan(palette: OnboardingFolioPagesPalette) -> some View {
        let shape = RoundedRectangle(cornerRadius: 5, style: .continuous)
        let fill = ink.stroke(3.1, 0.4)
        return ZStack(alignment: .topLeading) {
            shape
                .fill(Color.orange.opacity(0.75))
                .scaleEffect(x: 1, y: fill, anchor: .top)
            shape.onboardingFolioPagesInked(ink.stroke(2.9, 0.35), color: .orange, lineWidth: 1.6)
            Capsule()
                .fill(.white.opacity(0.85))
                .frame(width: 22, height: 3.5)
                .padding(6)
                .opacity(fill)
        }
    }
}
