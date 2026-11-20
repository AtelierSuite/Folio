import SwiftUI

struct OnboardingCarouselWelcomeScene: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var orbitStep = 0
    let features: [OnboardingFeature]
    let isActive: Bool

    private static let orbitRadius = CGSize(width: 128, height: 44)
    private static let restingAngle = 0.5 * .pi

    var body: some View {
        ZStack {
            Ellipse()
                .stroke(.white.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [4, 6]))
                .frame(width: Self.orbitRadius.width * 2, height: Self.orbitRadius.height * 2)
                .offset(y: 20)
            OnboardingCarouselAppTile()
                .offset(y: -6)
                .zIndex(1)
            ForEach(Array(features.enumerated()), id: \.element) { index, feature in
                let theta = angle(for: index)
                OnboardingCarouselOrbitBubble(feature: feature)
                    .opacity(0.7 + 0.3 * (sin(theta) + 1) / 2)
                    .modifier(OnboardingCarouselOrbitEffect(angle: theta, radius: Self.orbitRadius))
                    .zIndex(sin(theta) > 0 ? 2 : 0)
            }
        }
        .task(id: isActive) { await orbit() }
    }

    private func angle(for index: Int) -> Double {
        let slot = 2 * Double.pi / Double(max(features.count, 1))
        return Self.restingAngle + Double(index + orbitStep) * slot
    }

    private func orbit() async {
        guard isActive, !reducesMotion else { return }
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(2.2))
            guard !Task.isCancelled else { return }
            withAnimation(.smooth(duration: 1.3)) { orbitStep += 1 }
        }
    }
}

nonisolated struct OnboardingCarouselOrbitEffect: GeometryEffect {
    var angle: Double
    let radius: CGSize

    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let scale = 0.7 + 0.4 * (sin(angle) + 1) / 2
        let centred = CGAffineTransform(translationX: -size.width / 2, y: -size.height / 2)
            .concatenating(CGAffineTransform(scaleX: scale, y: scale))
            .concatenating(CGAffineTransform(
                translationX: size.width / 2 + cos(angle) * radius.width,
                y: size.height / 2 + 20 + sin(angle) * radius.height
            ))
        return ProjectionTransform(centred)
    }
}

private struct OnboardingCarouselAppTile: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(LinearGradient(
                colors: [Color.accentColor.opacity(0.75), Color.accentColor],
                startPoint: .top,
                endPoint: .bottom
            ))
            .overlay {
                VStack(alignment: .leading, spacing: 9) {
                    ForEach([0.75, 0.5, 0.9, 0.6], id: \.self) { fraction in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(.white.opacity(0.9))
                                .frame(width: 7, height: 7)
                            Capsule()
                                .fill(.white.opacity(0.85))
                                .frame(width: 66 * fraction, height: 7)
                        }
                    }
                }
                .frame(width: 84, alignment: .leading)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.6), .white.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            }
            .frame(width: 118, height: 118)
            .shadow(color: Color.accentColor.opacity(0.45), radius: 22, y: 12)
    }
}

private struct OnboardingCarouselOrbitBubble: View {
    let feature: OnboardingFeature

    var body: some View {
        Image(systemName: feature.systemImage)
            .font(.system(size: 22, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 54, height: 54)
            .background(
                LinearGradient(colors: feature.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing),
                in: .circle
            )
            .overlay { Circle().strokeBorder(.white.opacity(0.45), lineWidth: 1) }
            .shadow(color: .black.opacity(0.18), radius: 10, y: 5)
    }
}
