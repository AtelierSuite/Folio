import SwiftUI

struct OnboardingMorphingIconOrbitPlacement: ViewModifier, Animatable {
    var angle: Double
    var dockProgress: Double
    let radius: CGFloat
    let dock: CGSize

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(angle, dockProgress) }
        set {
            angle = newValue.first
            dockProgress = newValue.second
        }
    }

    func body(content: Content) -> some View {
        let orbit = OnboardingMorphingIconGeometry.offset(degrees: angle, radius: radius, verticalScale: 0.72)
        let depth = sin(angle * .pi / 180)
        let orbitScale = 0.86 + 0.14 * depth
        content
            .scaleEffect(orbitScale + (1 - orbitScale) * dockProgress)
            .opacity(0.75 + 0.25 * max(depth, dockProgress))
            .offset(
                x: orbit.width + (dock.width - orbit.width) * dockProgress,
                y: orbit.height + (dock.height - orbit.height) * dockProgress
            )
    }
}
