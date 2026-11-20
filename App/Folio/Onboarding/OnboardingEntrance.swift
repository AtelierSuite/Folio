import SwiftUI

struct OnboardingEntrance: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var isShown = false
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(isShown ? 1 : 0)
            .offset(y: isShown || reducesMotion ? 0 : 18)
            .onAppear {
                withAnimation(.spring(duration: 0.6, bounce: 0.2).delay(reducesMotion ? 0 : delay)) {
                    isShown = true
                }
            }
    }
}

extension View {
    func onboardingEntrance(delay: Double = 0) -> some View {
        modifier(OnboardingEntrance(delay: delay))
    }
}
