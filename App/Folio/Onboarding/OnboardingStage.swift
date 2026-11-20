import SwiftUI

struct OnboardingStage: Equatable {
    var displayedStep: OnboardingStep = .welcome
    var isTextHidden = false
    var completedCount = 0
    var lineIndex: Int?
    var highlightedIndex: Int?
    var declinedSteps: Set<OnboardingSetupStep> = []
    var isTransitioning = false

    static func settled(
        at step: OnboardingStep,
        index: Int?,
        declinedSteps: Set<OnboardingSetupStep>
    ) -> OnboardingStage {
        OnboardingStage(
            displayedStep: step,
            completedCount: index ?? 0,
            lineIndex: index,
            highlightedIndex: index,
            declinedSteps: declinedSteps
        )
    }

    @MainActor
    static func transition(
        _ stage: Binding<OnboardingStage>,
        to step: OnboardingStep,
        index: Int?,
        declinedSteps: Set<OnboardingSetupStep>,
        reducesMotion: Bool
    ) async {
        guard step != stage.wrappedValue.displayedStep else { return }
        guard !reducesMotion, let index else {
            stage.wrappedValue = settled(at: step, index: index, declinedSteps: declinedSteps)
            return
        }
        stage.wrappedValue.isTransitioning = true
        withAnimation(.easeOut(duration: 0.3)) { stage.wrappedValue.isTextHidden = true }
        try? await Task.sleep(for: .seconds(0.3))
        withAnimation(.spring(duration: 0.5, bounce: 0.4)) {
            stage.wrappedValue.completedCount = index
            stage.wrappedValue.highlightedIndex = nil
            stage.wrappedValue.declinedSteps = declinedSteps
        }
        withAnimation(.easeInOut(duration: 0.8)) { stage.wrappedValue.lineIndex = index }
        try? await Task.sleep(for: .seconds(index == 0 ? 0.2 : 0.8))
        withAnimation(.spring(duration: 0.5, bounce: 0.4)) { stage.wrappedValue.highlightedIndex = index }
        try? await Task.sleep(for: .seconds(0.35))
        withAnimation(.smooth(duration: 0.5)) {
            stage.wrappedValue.displayedStep = step
            stage.wrappedValue.isTextHidden = false
        }
        stage.wrappedValue.isTransitioning = false
    }
}
