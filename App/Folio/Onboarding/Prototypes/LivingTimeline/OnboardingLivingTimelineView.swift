import SwiftUI

struct OnboardingLivingTimelineView: View {
    let context: OnboardingPrototypeContext

    var body: some View {
        OnboardingTimelineCardsView(context: context)
    }
}
