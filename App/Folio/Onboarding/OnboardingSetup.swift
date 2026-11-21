import Planner
import SwiftUI

@MainActor
struct OnboardingSetup {
    let permissions: PermissionCenter
    let scheduler: NotificationScheduler
    let weather: WeatherStore

    var pendingSteps: [OnboardingSetupStep] {
        OnboardingSetupStep.allCases.filter { isOffered($0) && !isSetUp($0) }
    }

    func setUp(_ step: OnboardingSetupStep) async {
        switch step {
        case .calendar, .reminders, .alarms:
            await permissions.request(step.permission)
        case .alerts:
            await scheduler.setEnabled(true)
            await permissions.refresh(.notifications)
        case .weather:
            weather.setEnabled(true)
            await permissions.request(.location)
            weather.locationAuthorizationDidChange()
        }
    }

    private func isOffered(_ step: OnboardingSetupStep) -> Bool {
        permissions.isAvailable(step.permission)
    }

    func isGranted(_ step: OnboardingSetupStep) -> Bool {
        permissions.status(of: step.permission) == .granted
    }

    private func isSetUp(_ step: OnboardingSetupStep) -> Bool {
        switch step {
        case .calendar, .reminders, .alarms: isGranted(step)
        case .alerts: scheduler.isEnabled
        case .weather: weather.isEnabled
        }
    }
}
