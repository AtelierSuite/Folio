import SwiftUI

struct OnboardingFinalBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @Environment(\.colorScheme) private var colorScheme
    let step: OnboardingStep

    var body: some View {
        ZStack {
            OnboardingFinalMesh(
                colors: OnboardingFinalPalette.meshColors(for: step, deepened: colorScheme == .dark),
                drifts: !reducesMotion
            )
            .id(step)
            .transition(.opacity)
        }
        .animation(.easeInOut(duration: 0.9), value: step)
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

private struct OnboardingFinalMesh: View {
    let colors: [Color]
    let drifts: Bool

    var body: some View {
        TimelineView(.animation(paused: !drifts)) { timeline in
            MeshGradient(
                width: 3,
                height: 3,
                points: points(at: drifts ? timeline.date.timeIntervalSinceReferenceDate : 0),
                colors: colors,
                smoothsColors: true
            )
        }
    }

    private func points(at time: TimeInterval) -> [SIMD2<Float>] {
        let slowTime = Float(time.truncatingRemainder(dividingBy: 10_000)) * 0.35
        func wave(_ phase: Float, _ amplitude: Float) -> Float {
            sin(slowTime + phase) * amplitude
        }
        return [
            [0, 0], [0.5 + wave(0.4, 0.12), 0], [1, 0],
            [0, 0.5 + wave(1.3, 0.1)],
            [0.5 + wave(2.1, 0.16), 0.5 + wave(0.7, 0.14)],
            [1, 0.5 + wave(2.9, 0.1)],
            [0, 1], [0.5 + wave(3.6, 0.12), 1], [1, 1]
        ]
    }
}
