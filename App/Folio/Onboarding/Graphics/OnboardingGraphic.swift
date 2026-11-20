import SwiftUI

struct OnboardingGraphic: View {
    let step: OnboardingSetupStep

    var body: some View {
        Group {
            switch step {
            case .calendar: OnboardingCalendarGraphic()
            case .reminders: OnboardingRemindersGraphic()
            case .alerts: OnboardingAlertsGraphic()
            case .weather: OnboardingWeatherGraphic()
            case .sleep: OnboardingSleepGraphic()
            }
        }
        .accessibilityHidden(true)
    }
}
