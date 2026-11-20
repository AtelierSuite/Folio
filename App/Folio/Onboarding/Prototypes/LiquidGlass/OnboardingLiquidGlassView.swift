import SwiftUI

struct OnboardingLiquidGlassView: View {
    let context: OnboardingPrototypeContext

    var body: some View {
        OnboardingTimelineCardsView(context: context)
    }
}
