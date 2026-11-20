import SwiftUI

struct OnboardingProductTourScreen: View {
    let step: OnboardingStep

    var body: some View {
        ZStack(alignment: .top) {
            demo
                .id(step)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            #if !os(macOS)
            OnboardingProductTourStatusBar()
                .blendMode(.difference)
            #endif
        }
        .compositingGroup()
        .clipped()
    }

    @ViewBuilder private var demo: some View {
        switch step {
        case .welcome: OnboardingProductTourBootDemo()
        case .setup(.calendar): OnboardingProductTourCalendarDemo()
        case .setup(.reminders): OnboardingProductTourRemindersDemo()
        case .setup(.alerts): OnboardingProductTourAlertsDemo()
        case .setup(.weather): OnboardingProductTourWeatherDemo()
        case .setup(.sleep): OnboardingProductTourSleepDemo()
        }
    }
}
