import SwiftUI

struct OnboardingMorphingIconTile: View {
    let symbol: String
    let colors: [Color]
    let size: CGFloat
    let flipCount: Int
    let shakeCount: Int
    let bounceCount: Int

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: size * 0.27, style: .continuous)
    }

    var body: some View {
        face
            .frame(width: size, height: size)
            .keyframeAnimator(initialValue: 0.0, trigger: flipCount) { content, angle in
                content.rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0), perspective: 0.55)
            } keyframes: { _ in
                CubicKeyframe(90, duration: 0.2)
                MoveKeyframe(-90)
                SpringKeyframe(0, duration: 0.65, spring: .bouncy(duration: 0.65, extraBounce: 0.1))
            }
            .keyframeAnimator(initialValue: 0.0, trigger: shakeCount) { content, angle in
                content.rotationEffect(.degrees(angle))
            } keyframes: { _ in
                CubicKeyframe(-8, duration: 0.07)
                CubicKeyframe(8, duration: 0.09)
                CubicKeyframe(-6, duration: 0.09)
                CubicKeyframe(5, duration: 0.09)
                CubicKeyframe(-2, duration: 0.08)
                CubicKeyframe(0, duration: 0.08)
            }
            .shadow(color: (colors.last ?? .black).opacity(0.45), radius: size * 0.2, y: size * 0.2)
            .shadow(color: .black.opacity(0.12), radius: 3, y: 2)
    }

    private var face: some View {
        shape
            .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay { gloss }
            .overlay { innerHighlight }
            .overlay {
                Image(systemName: symbol)
                    .font(.system(size: size * 0.42, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                    .contentTransition(.symbolEffect(.replace))
                    .symbolEffect(.bounce, value: bounceCount)
            }
    }

    private var gloss: some View {
        shape.fill(LinearGradient(
            stops: [
                .init(color: .white.opacity(0.34), location: 0),
                .init(color: .white.opacity(0.08), location: 0.48),
                .init(color: .white.opacity(0), location: 0.5)
            ],
            startPoint: .top,
            endPoint: .bottom
        ))
    }

    private var innerHighlight: some View {
        shape.strokeBorder(
            LinearGradient(
                colors: [.white.opacity(0.6), .white.opacity(0.08), .black.opacity(0.12)],
                startPoint: .top,
                endPoint: .bottom
            ),
            lineWidth: 1.5
        )
    }
}
