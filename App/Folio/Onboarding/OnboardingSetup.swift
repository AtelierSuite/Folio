import Planner
import SwiftUI

@MainActor
struct OnboardingSetup {
    let permissions: PermissionCenter
    let scheduler: NotificationScheduler
    let weather: WeatherStore
    let sleep: SleepStore
    let capabilities: PlatformCapabilities

    var pendingSteps: [OnboardingSetupStep] {
        OnboardingSetupStep.allCases.filter { isOffered($0) && !isSetUp($0) }
    }

    func setUp(_ step: OnboardingSetupStep) async {
        switch step {
        case .calendar, .reminders:
            await permissions.request(step.permission)
        case .alerts:
            await scheduler.setEnabled(true)
            await permissions.refresh(.notifications)
        case .weather:
            weather.setEnabled(true)
            await permissions.request(.location)
            weather.locationAuthorizationDidChange()
        case .sleep:
            guard await permissions.allowsTurningOn(true, needing: .health) else { return }
            sleep.setShownOnTimeline(true)
        }
    }

    private func isOffered(_ step: OnboardingSetupStep) -> Bool {
        guard permissions.isAvailable(step.permission) else { return false }
        return step != .sleep || (capabilities.supports(.sleep) && sleep.isAvailable)
    }

    private func isSetUp(_ step: OnboardingSetupStep) -> Bool {
        switch step {
        case .calendar, .reminders: permissions.status(of: step.permission) == .granted
        case .alerts: scheduler.isEnabled
        case .weather: weather.isEnabled
        case .sleep: sleep.isShownOnTimeline
        }
    }
}
