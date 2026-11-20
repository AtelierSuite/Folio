import SwiftUI

struct OnboardingColorFieldsHero: View {
    let context: OnboardingPrototypeContext

    var body: some View {
        switch context.step {
        case .welcome: OnboardingColorFieldsWelcomeHero(features: context.features)
        case .setup(.calendar): OnboardingColorFieldsCalendarHero()
        case .setup(.reminders): OnboardingColorFieldsRemindersHero()
        case .setup(.alerts): OnboardingColorFieldsAlertsHero()
        case .setup(.weather): OnboardingColorFieldsWeatherHero()
        case .setup(.sleep): OnboardingColorFieldsSleepHero()
        }
    }
}

struct OnboardingColorFieldsSymbol: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: Self.size, weight: .semibold))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.18), radius: 24, y: 12)
    }

    #if os(macOS)
    static let size: CGFloat = 120
    #else
    static let size: CGFloat = 148
    #endif
}

extension View {
    func onboardingColorFieldsSymbol() -> some View {
        modifier(OnboardingColorFieldsSymbol())
    }
}
