import SwiftUI

struct OnboardingFolioPagesPage: View {
    let step: OnboardingStep
    let features: [OnboardingFeature]
    let animates: Bool
    let inkDelay: TimeInterval

    private typealias Metrics = OnboardingFolioPagesMetrics

    var body: some View {
        OnboardingFolioPagesPaper()
            .overlay {
                OnboardingFolioPagesInkCanvas(animates: animates, delay: inkDelay, duration: 5.5) { ink in
                    sketch(ink: ink)
                }
                .padding(.leading, Metrics.marginInset + 8)
                .padding(.trailing, 18)
                .padding(.vertical, 22)
            }
            .frame(width: Metrics.pageSize.width, height: Metrics.pageSize.height)
    }

    @ViewBuilder
    private func sketch(ink: OnboardingFolioPagesInk) -> some View {
        switch step {
        case .welcome:
            OnboardingFolioPagesWelcomeSketch(features: features, ink: ink)
        case .setup(.calendar):
            OnboardingFolioPagesCalendarSketch(ink: ink)
        case .setup(.reminders):
            OnboardingFolioPagesRemindersSketch(ink: ink)
        case .setup(.alerts):
            OnboardingFolioPagesAlertsSketch(ink: ink)
        case .setup(.weather):
            OnboardingFolioPagesWeatherSketch(ink: ink)
        case .setup(.sleep):
            OnboardingFolioPagesSleepSketch(ink: ink)
        }
    }
}
