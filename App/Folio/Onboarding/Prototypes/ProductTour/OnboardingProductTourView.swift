import SwiftUI

struct OnboardingProductTourView: View {
    let context: OnboardingPrototypeContext

    var body: some View {
        OnboardingTimelineCardsView(context: context)
    }
}
