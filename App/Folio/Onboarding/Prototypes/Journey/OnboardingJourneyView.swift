import SwiftUI

struct OnboardingJourneyView: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @Namespace private var milestones
    @State private var shownStep: OnboardingStep = .welcome
    @State private var landedStep: OnboardingSetupStep?
    @State private var segmentProgress: Double = 1
    let context: OnboardingPrototypeContext

    var body: some View {
        OnboardingJourneyLayout(
            buttonTitle: context.buttonTitle,
            buttonIdentifier: context.buttonIdentifier,
            glow: glow,
            action: context.advance
        ) {
            switch shownStep {
            case .welcome:
                OnboardingJourneyWelcome(
                    features: context.features,
                    steps: context.plannedSteps,
                    namespace: milestones
                )
                .transition(.opacity)
            case .setup(let step):
                OnboardingJourneySetup(
                    step: step,
                    steps: context.plannedSteps,
                    isLanded: landedStep == step,
                    segmentProgress: segmentProgress,
                    namespace: milestones
                )
                .transition(.opacity)
            }
        }
        .task(id: context.step) { await travel(to: context.step) }
    }

    private var glow: Color {
        if case .setup(let step) = shownStep {
            OnboardingJourneyPalette.tint(for: step)
        } else {
            .accentColor
        }
    }

    private func travel(to step: OnboardingStep) async {
        guard case .setup(let setupStep) = step else {
            shownStep = step
            return
        }
        guard !reducesMotion else {
            shownStep = step
            landedStep = setupStep
            segmentProgress = 1
            return
        }
        withAnimation(.spring(duration: 0.8, bounce: 0.2)) {
            shownStep = step
            landedStep = nil
            segmentProgress = 0
        }
        do {
            try await Task.sleep(for: .milliseconds(550))
            withAnimation(.easeInOut(duration: 0.7)) { segmentProgress = 1 }
            try await Task.sleep(for: .milliseconds(650))
            withAnimation(.spring(duration: 0.75, bounce: 0.3)) { landedStep = setupStep }
        } catch {
            return
        }
    }
}
