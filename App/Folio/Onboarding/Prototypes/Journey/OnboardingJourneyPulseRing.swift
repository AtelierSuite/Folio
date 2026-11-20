import SwiftUI

struct OnboardingJourneyPulseRing: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    let tint: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.14))
            Circle()
                .strokeBorder(tint, lineWidth: 2.5)
                .shadow(color: tint.opacity(0.8), radius: 6)
            if !reducesMotion {
                Circle()
                    .stroke(tint.opacity(0.7), lineWidth: 2)
                    .phaseAnimator([false, true]) { ring, isExpanded in
                        ring
                            .scaleEffect(isExpanded ? 1.5 : 1)
                            .opacity(isExpanded ? 0 : 0.9)
                    } animation: { isExpanded in
                        isExpanded ? .easeOut(duration: 1.5) : .linear(duration: 0.001)
                    }
            }
        }
    }
}
