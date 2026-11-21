import Planner
import SwiftUI

struct OnboardingView: View {
    @Environment(PermissionCenter.self) private var permissions
    @Environment(NotificationScheduler.self) private var scheduler
    @Environment(WeatherStore.self) private var weather
    @State private var step: OnboardingStep = .welcome
    @State private var plannedSteps: [OnboardingSetupStep] = []
    @State private var remainingSteps: [OnboardingSetupStep] = []
    let onFinish: () -> Void

    var body: some View {
        OnboardingContent(context: context)
            #if !os(macOS)
            .presentationDragIndicator(.hidden)
            #endif
    }

    private var context: OnboardingContext {
        OnboardingContext(
            step: step,
            plannedSteps: step == .welcome ? pendingSteps : plannedSteps,
            features: OnboardingFeature.allCases,
            advance: advanceFromCurrentStep,
            declinedSteps: declinedSteps
        )
    }

    private var declinedSteps: Set<OnboardingSetupStep> {
        guard case .setup(let current) = step, let index = plannedSteps.firstIndex(of: current) else { return [] }
        return Set(plannedSteps.prefix(index).filter { !setup.isGranted($0) })
    }

    private var pendingSteps: [OnboardingSetupStep] {
        setup.pendingSteps
    }

    private var setup: OnboardingSetup {
        OnboardingSetup(
            permissions: permissions,
            scheduler: scheduler,
            weather: weather
        )
    }

    private func advanceFromCurrentStep() {
        switch step {
        case .welcome:
            plannedSteps = pendingSteps
            remainingSteps = plannedSteps
            advance()
        case .setup(let setupStep):
            Task {
                await setup.setUp(setupStep)
                advance()
            }
        }
    }

    private func advance() {
        guard !remainingSteps.isEmpty else { return onFinish() }
        step = .setup(remainingSteps.removeFirst())
    }
}
