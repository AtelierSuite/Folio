import SwiftUI

struct OnboardingProductTourStage: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    let step: OnboardingStep

    var body: some View {
        OnboardingProductTourDevice {
            OnboardingProductTourScreen(step: step)
        }
        .keyframeAnimator(initialValue: OnboardingProductTourTilt(), trigger: step) { device, tilt in
            device
                .rotation3DEffect(
                    .degrees(reducesMotion ? 0 : tilt.angle),
                    axis: (x: 0.15, y: 1, z: 0),
                    perspective: 0.5
                )
                .scaleEffect(reducesMotion ? 1 : tilt.scale)
        } keyframes: { _ in
            KeyframeTrack(\.angle) {
                CubicKeyframe(-14, duration: 0.3)
                SpringKeyframe(0, duration: 0.9, spring: .bouncy)
            }
            KeyframeTrack(\.scale) {
                CubicKeyframe(0.95, duration: 0.3)
                SpringKeyframe(1, duration: 0.9, spring: .bouncy)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: OnboardingProductTourMetrics.stageHeight)
        .background { glow }
        .accessibilityHidden(true)
    }

    private var glow: some View {
        Ellipse()
            .fill(RadialGradient(
                colors: [tint.opacity(0.32), tint.opacity(0)],
                center: .center,
                startRadius: 0,
                endRadius: OnboardingProductTourMetrics.stageHeight * 0.6
            ))
            .frame(width: OnboardingProductTourMetrics.stageHeight * 1.4)
    }

    private var tint: Color {
        switch step {
        case .welcome: .accentColor
        case .setup(.calendar): .red
        case .setup(.reminders): .orange
        case .setup(.alerts), .setup(.alarms): .pink
        case .setup(.weather): .blue
        case .setup(.sleep): .indigo
        }
    }
}

nonisolated struct OnboardingProductTourTilt {
    var angle = 0.0
    var scale = 1.0
}
