import SwiftUI

struct OnboardingColorFieldsAlertsHero: View {
    private static let markerPositions: [CGFloat] = [0.06, 0.32, 0.52, 0.74]
    private static let alertPosition: CGFloat = 0.52
    private static let eventPosition: CGFloat = 0.74

    var body: some View {
        OnboardingSequencePlayer(count: 3, interval: .milliseconds(900), hold: .seconds(2)) { progress in
            let hasFired = progress >= 2
            VStack(spacing: 30) {
                ZStack {
                    OnboardingColorFieldsPulseRings(isActive: progress == 2)
                    Image(systemName: hasFired ? "bell.badge.fill" : "bell.fill")
                        .contentTransition(.symbolEffect(.replace))
                        .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(delay: 0.2)), isActive: progress == 2)
                        .onboardingColorFieldsSymbol()
                }
                track(progress: progress, hasFired: hasFired)
            }
        }
    }

    private func track(progress: Int, hasFired: Bool) -> some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.25))
                    .frame(height: 4)
                Capsule()
                    .fill(.white)
                    .frame(width: width * 0.22, height: 18)
                    .offset(x: width * Self.eventPosition)
                Circle()
                    .fill(.white.opacity(hasFired ? 1 : 0.5))
                    .frame(width: 8, height: 8)
                    .offset(x: width * Self.alertPosition - 4)
                Circle()
                    .fill(.white)
                    .frame(width: 14, height: 14)
                    .shadow(color: .white.opacity(0.7), radius: 6)
                    .offset(x: width * Self.markerPositions[min(progress, Self.markerPositions.count - 1)] - 7)
            }
            .frame(height: proxy.size.height)
        }
        .frame(width: 240, height: 20)
    }
}

private struct OnboardingColorFieldsPulseRings: View {
    let isActive: Bool

    var body: some View {
        ZStack {
            ForEach(0..<2, id: \.self) { ring in
                Circle()
                    .strokeBorder(.white, lineWidth: 2)
                    .phaseAnimator([0, 1, 2], trigger: isActive) { content, phase in
                        content
                            .opacity(isActive && phase == 1 ? 0.6 : 0)
                            .scaleEffect(phase == 2 ? 1.5 + Double(ring) * 0.3 : 0.9)
                    } animation: { phase in
                        phase == 2 ? .easeOut(duration: 1.1).delay(Double(ring) * 0.25) : nil
                    }
            }
        }
        .frame(width: OnboardingColorFieldsSymbol.size * 1.1, height: OnboardingColorFieldsSymbol.size * 1.1)
    }
}
