import SwiftUI

struct OnboardingPrototypeView: View {
    let prototype: OnboardingPrototype
    let context: OnboardingPrototypeContext

    var body: some View {
        switch prototype {
        case .timelineCards: OnboardingTimelineCardsView(context: context)
        case .carousel: OnboardingCarouselView(context: context)
        case .livingTimeline: OnboardingLivingTimelineView(context: context)
        case .colorFields: OnboardingColorFieldsView(context: context)
        case .liquidGlass: OnboardingLiquidGlassView(context: context)
        case .folioPages: OnboardingFolioPagesView(context: context)
        case .particles: OnboardingParticlesView(context: context)
        case .productTour: OnboardingProductTourView(context: context)
        case .journey: OnboardingJourneyView(context: context)
        case .morphingIcon: OnboardingMorphingIconView(context: context)
        }
    }
}
