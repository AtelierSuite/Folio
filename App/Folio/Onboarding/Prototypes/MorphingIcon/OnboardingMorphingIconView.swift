import SwiftUI

struct OnboardingMorphingIconView: View {
    let context: OnboardingPrototypeContext

    var body: some View {
        OnboardingTimelineCardsView(context: context)
    }
}
