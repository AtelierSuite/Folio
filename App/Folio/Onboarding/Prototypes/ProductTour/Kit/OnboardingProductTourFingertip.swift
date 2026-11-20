import SwiftUI

struct OnboardingProductTourFingertip: View {
    let position: CGPoint
    let isVisible: Bool
    var isPressed = false
    var tapCount = 0

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(Color.accentColor, lineWidth: 2)
                .keyframeAnimator(
                    initialValue: OnboardingProductTourRipple(),
                    trigger: tapCount
                ) { ring, ripple in
                    ring
                        .scaleEffect(ripple.scale)
                        .opacity(ripple.opacity)
                } keyframes: { _ in
                    KeyframeTrack(\.scale) {
                        LinearKeyframe(0.7, duration: 0.01)
                        CubicKeyframe(2.4, duration: 0.6)
                    }
                    KeyframeTrack(\.opacity) {
                        LinearKeyframe(0.9, duration: 0.01)
                        CubicKeyframe(0, duration: 0.6)
                    }
                }
            Circle()
                .fill(Color.gray.opacity(isPressed ? 0.55 : 0.4))
                .overlay(Circle().strokeBorder(.white.opacity(0.9), lineWidth: 1.5))
                .overlay(Circle().stroke(.black.opacity(0.1), lineWidth: 0.5))
                .shadow(color: .black.opacity(isPressed ? 0.15 : 0.3), radius: isPressed ? 2 : 5, y: isPressed ? 1 : 3)
                .scaleEffect(isPressed ? 0.82 : 1)
        }
        .frame(width: OnboardingProductTourMetrics.fingertipSize, height: OnboardingProductTourMetrics.fingertipSize)
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 1.3)
        .position(position)
        .allowsHitTesting(false)
    }
}

nonisolated struct OnboardingProductTourRipple {
    var scale = 1.0
    var opacity = 0.0
}
