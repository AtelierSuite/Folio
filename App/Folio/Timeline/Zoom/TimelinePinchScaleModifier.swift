import SwiftUI

/// Stretches the already laid out timeline while pinching; it's laid out again at each detail step.
struct TimelinePinchScaleModifier: ViewModifier {
    let pinch: TimelinePinchState

    func body(content: Content) -> some View {
        content
            .scaleEffect(x: 1, y: pinch.scale, anchor: UnitPoint(x: 0.5, y: pinch.anchor))
    }
}
