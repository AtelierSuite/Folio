import SwiftUI

struct OnboardingFolioPagesWeatherSketch: View {
    let ink: OnboardingFolioPagesInk
    @Environment(\.colorScheme) private var colorScheme

    private let forecastPoints = [
        CGPoint(x: 0, y: 0.7), CGPoint(x: 0.25, y: 0.35), CGPoint(x: 0.5, y: 0.5),
        CGPoint(x: 0.75, y: 0.15), CGPoint(x: 1, y: 0.4)
    ]

    var body: some View {
        let palette = OnboardingFolioPagesPalette(colorScheme: colorScheme)
        GeometryReader { proxy in
            let size = proxy.size
            OnboardingFolioPagesPin()
                .fill(Color.blue.opacity(0.2 * ink.stroke(0.7, 0.3)))
                .onboardingFolioPagesPlaced(in: size, horizontal: 0.13, vertical: 0.78, width: 0.2, height: 0.26)
            OnboardingFolioPagesPin()
                .onboardingFolioPagesInked(ink.stroke(0.1, 0.7), color: .blue, lineWidth: 2.2)
                .onboardingFolioPagesPlaced(in: size, horizontal: 0.13, vertical: 0.78, width: 0.2, height: 0.26)
            sun
                .onboardingFolioPagesPlaced(in: size, horizontal: 0.48, vertical: 0.3, side: 0.5)
            OnboardingFolioPagesCloud()
                .fill(palette.paper.opacity(ink.stroke(1.6, 0.3)))
                .overlay {
                    OnboardingFolioPagesCloud()
                        .onboardingFolioPagesInked(
                            ink.stroke(1.6, 0.8),
                            color: palette.ink.opacity(0.75),
                            lineWidth: 2,
                            dash: [6, 4]
                        )
                }
                .onboardingFolioPagesPlaced(in: size, horizontal: 0.74, vertical: 0.43, width: 0.46, height: 0.26)
                .offset(x: 30 * (1 - ink.stroke(1.6, 1)))
            OnboardingFolioPagesCurve(points: forecastPoints)
                .onboardingFolioPagesInked(ink.stroke(2.4, 0.9), color: .orange, lineWidth: 2.6)
                .onboardingFolioPagesPlaced(in: size, horizontal: 0.66, vertical: 0.84, width: 0.62, height: 0.16)
            ForEach([0, forecastPoints.count - 1], id: \.self) { index in
                let point = forecastPoints[index]
                Circle()
                    .fill(Color.orange)
                    .frame(width: 7, height: 7)
                    .scaleEffect(ink.stroke(2.4 + 0.9 * point.x, 0.2))
                    .position(
                        x: size.width * (0.35 + 0.62 * point.x),
                        y: size.height * (0.76 + 0.16 * point.y)
                    )
            }
        }
    }

    private var sun: some View {
        ZStack {
            Circle()
                .fill(Color.yellow.opacity(0.35 * ink.stroke(1, 0.4)))
                .padding(18)
            Circle()
                .onboardingFolioPagesInked(ink.stroke(0.6, 0.6), color: .orange, lineWidth: 2.4)
                .rotationEffect(.degrees(-90))
                .padding(18)
            OnboardingFolioPagesSunRays(count: 10)
                .onboardingFolioPagesInked(ink.stroke(1.1, 0.7), color: .orange, lineWidth: 2.2)
                .rotationEffect(.degrees(ink.isFinished ? 0 : ink.time * 4))
        }
    }
}
