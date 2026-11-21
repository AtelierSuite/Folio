import SwiftUI

struct OnboardingContent: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var stage = OnboardingStage()
    let context: OnboardingContext

    var body: some View {
        #if os(macOS)
        VStack(spacing: 0) {
            content
                .padding(.horizontal, 28)
                .padding(.top, 20)
                .padding(.bottom, 20)
            button
                .padding(.horizontal, 28)
                .padding(.bottom, 24)
        }
        .frame(width: 460)
        .fixedSize(horizontal: false, vertical: true)
        .background { OnboardingBackground(step: stage.displayedStep) }
        .task(id: context.step) { await transition() }
        #else
        ScrollView {
            content
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaBar(edge: .bottom, spacing: 0) {
            button
                .frame(maxWidth: 560)
                .padding(24)
        }
        .background { OnboardingBackground(step: stage.displayedStep) }
        .task(id: context.step) { await transition() }
        #endif
    }

    private var displayedContext: OnboardingContext {
        OnboardingContext(
            step: stage.displayedStep,
            plannedSteps: context.plannedSteps,
            features: context.features,
            advance: context.advance,
            declinedSteps: stage.declinedSteps
        )
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            GlassEffectContainer(spacing: 4) {
                VStack(alignment: .leading, spacing: OnboardingTrailLayout.spacing) {
                    OnboardingTrail(steps: context.plannedSteps, stage: stage)
                    OnboardingTimeline(context: displayedContext)
                }
            }
            .onboardingNowLineOverlay()
            OnboardingText(context: displayedContext)
                .opacity(stage.isTextHidden ? 0 : 1)
                .padding(.top, Metrics.textSpacing)
        }
    }

    private var button: some View {
        OnboardingButton(context: context)
    }

    private func transition() async {
        await OnboardingStage.transition(
            $stage,
            to: context.step,
            index: context.currentIndex,
            declinedSteps: context.declinedSteps,
            reducesMotion: reducesMotion
        )
    }

    private enum Metrics {
        #if os(macOS)
        static let textSpacing: CGFloat = 20
        #else
        static let textSpacing: CGFloat = 28
        #endif
    }
}
