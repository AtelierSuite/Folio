import SwiftUI

struct OnboardingLivingTimelineLayerStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let state: OnboardingLivingTimelineLayerState

    func body(content: Content) -> some View {
        let isDimmed = state == .completed
        content
            .saturation(isDimmed ? 0.45 : 1)
            .brightness(isDimmed ? (colorScheme == .dark ? -0.12 : 0.1) : 0)
            .animation(.easeInOut(duration: 0.6), value: state)
    }
}

struct OnboardingLivingTimelinePulsingOutline<Outline: InsettableShape>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    let isActive: Bool
    let shape: Outline
    let color: Color

    func body(content: Content) -> some View {
        content.overlay {
            if isActive {
                if reducesMotion {
                    shape.strokeBorder(color.opacity(0.8), lineWidth: 1.5)
                } else {
                    shape
                        .strokeBorder(color, lineWidth: 1.5)
                        .phaseAnimator([0.25, 0.95]) { outline, phase in
                            outline.opacity(phase)
                        } animation: { _ in .easeInOut(duration: 1.1) }
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: isActive)
    }
}

extension View {
    func livingTimelineLayer(_ state: OnboardingLivingTimelineLayerState) -> some View {
        modifier(OnboardingLivingTimelineLayerStyle(state: state))
    }

    func livingTimelineOutline(
        _ isActive: Bool,
        shape: some InsettableShape,
        color: Color
    ) -> some View {
        modifier(OnboardingLivingTimelinePulsingOutline(isActive: isActive, shape: shape, color: color))
    }
}
