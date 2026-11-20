import SwiftUI

struct OnboardingCarouselView: View {
    let context: OnboardingPrototypeContext

    var body: some View {
        OnboardingTimelineCardsView(context: context)
    }
}
