import Planner
import SwiftUI

struct OnboardingView: View {
    @Environment(PermissionCenter.self) private var permissions
    @Environment(NotificationScheduler.self) private var scheduler
    @Environment(WeatherStore.self) private var weather
    @Environment(SleepStore.self) private var sleep
    @Environment(\.platformCapabilities) private var capabilities
    @State private var step: OnboardingStep = .welcome
    @State private var plannedSteps: [OnboardingSetupStep] = []
    @State private var remainingSteps: [OnboardingSetupStep] = []
    private let prototype = OnboardingPrototype.selected
    let onFinish: () -> Void

    var body: some View {
        OnboardingPrototypeView(prototype: prototype, context: context)
            #if !os(macOS)
            .presentationDragIndicator(.hidden)
            #endif
    }

    private var context: OnboardingPrototypeContext {
        OnboardingPrototypeContext(
            step: step,
            plannedSteps: step == .welcome ? pendingSteps : plannedSteps,
            features: OnboardingFeature.offered(by: capabilities).filter { !prototype.excludedFeatures.contains($0) },
            advance: advanceFromCurrentStep,
            declinedSteps: declinedSteps
        )
    }

    private var declinedSteps: Set<OnboardingSetupStep> {
        guard case .setup(let current) = step, let index = plannedSteps.firstIndex(of: current) else { return [] }
        return Set(plannedSteps.prefix(index).filter { !setup.isGranted($0) })
    }

    private var pendingSteps: [OnboardingSetupStep] {
        setup.pendingSteps.filter { !prototype.excludedSteps.contains($0) }
    }

    private var setup: OnboardingSetup {
        OnboardingSetup(
            permissions: permissions,
            scheduler: scheduler,
            weather: weather,
            sleep: sleep,
            capabilities: capabilities
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
