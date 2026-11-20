import SwiftUI

struct OnboardingFolioPagesAlertsSketch: View {
    let ink: OnboardingFolioPagesInk
    @Environment(\.colorScheme) private var colorScheme

    private static let lineY: CGFloat = 0.84
    private static let alertX: CGFloat = 0.36
    private static let eventRange: ClosedRange<CGFloat> = 0.56...0.94
    private static let ringStarts: [TimeInterval] = [2.1, 3.5]

    var body: some View {
        let palette = OnboardingFolioPagesPalette(colorScheme: colorScheme)
        GeometryReader { proxy in
            let size = proxy.size
            let bellSide = min(size.width, size.height) * 0.42
            let bellCenter = CGPoint(x: size.width * Self.alertX, y: size.height * 0.3)
            OnboardingFolioPagesCurve(points: [CGPoint(x: 0, y: 0.5), CGPoint(x: 1, y: 0.5)])
                .onboardingFolioPagesInked(ink.stroke(0.2, 0.7), color: palette.ink.opacity(0.6), lineWidth: 1.6)
                .frame(width: size.width, height: 2)
                .position(x: size.width / 2, y: size.height * Self.lineY)
            event(palette: palette)
                .frame(
                    width: size.width * (Self.eventRange.upperBound - Self.eventRange.lowerBound),
                    height: size.height * 0.18
                )
                .position(
                    x: size.width * (Self.eventRange.lowerBound + Self.eventRange.upperBound) / 2,
                    y: size.height * (Self.lineY - 0.11)
                )
            Circle()
                .fill(Color.red)
                .frame(width: 9, height: 9)
                .scaleEffect(ink.stroke(1.35, 0.25))
                .position(x: size.width * Self.alertX, y: size.height * Self.lineY)
            OnboardingFolioPagesCurve(points: [CGPoint(x: 0.5, y: 1), CGPoint(x: 0.5, y: 0)])
                .onboardingFolioPagesInked(ink.stroke(1.5, 0.5), color: .red.opacity(0.7), lineWidth: 1.6, dash: [3, 4])
                .frame(width: 2, height: size.height * (Self.lineY - 0.04) - (bellCenter.y + bellSide / 2))
                .position(
                    x: bellCenter.x,
                    y: (size.height * (Self.lineY - 0.04) + bellCenter.y + bellSide / 2) / 2
                )
            OnboardingFolioPagesRingLines()
                .onboardingFolioPagesInked(ink.stroke(Self.ringStarts[0], 0.4), color: .red.opacity(0.8), lineWidth: 2)
                .frame(width: bellSide * 1.9, height: bellSide * 1.9)
                .position(bellCenter)
            bell(palette: palette)
                .frame(width: bellSide, height: bellSide)
                .rotationEffect(.degrees(ringAngle), anchor: .top)
                .position(bellCenter)
        }
    }

    private var ringAngle: Double {
        Self.ringStarts.reduce(0) { angle, start in
            angle + ink.swing(start, 1.1, swings: 4) * 16
        }
    }

    private func bell(palette: OnboardingFolioPagesPalette) -> some View {
        ZStack {
            OnboardingFolioPagesBell()
                .fill(Color.red.opacity(0.18 * ink.stroke(1.1, 0.4)))
            OnboardingFolioPagesBell()
                .onboardingFolioPagesInked(ink.stroke(0.5, 0.8), color: palette.ink.opacity(0.85), lineWidth: 2.4)
        }
    }

    private func event(palette: OnboardingFolioPagesPalette) -> some View {
        let shape = RoundedRectangle(cornerRadius: 5, style: .continuous)
        let fill = ink.stroke(0.95, 0.4)
        return ZStack(alignment: .topLeading) {
            shape
                .fill(Color.accentColor.opacity(0.75))
                .scaleEffect(x: fill, y: 1, anchor: .leading)
            shape.onboardingFolioPagesInked(ink.stroke(0.7, 0.35), color: .accentColor, lineWidth: 1.6)
            Capsule()
                .fill(.white.opacity(0.85))
                .frame(width: 26, height: 3.5)
                .padding(7)
                .opacity(fill)
        }
    }
}
