import SwiftUI

struct OnboardingLiquidGlassView: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var displayedStep: OnboardingStep?
    @State private var phase = 0
    let context: OnboardingPrototypeContext

    private var step: OnboardingStep { displayedStep ?? context.step }

    var body: some View {
        content
            .background(alignment: .top) {
                OnboardingLiquidGlassBackdrop(colors: OnboardingLiquidGlassScript(step: step).backdropColors)
                    .accessibilityHidden(true)
                    #if !os(macOS)
                    .ignoresSafeArea()
                    #endif
            }
            .onChange(of: context.step) { _, newStep in
                withAnimation(reducesMotion ? nil : .bouncy(duration: 0.8, extraBounce: 0.05)) {
                    displayedStep = newStep
                    phase = reducesMotion ? OnboardingLiquidGlassScript(step: newStep).finalPhase : 0
                }
            }
            .task(id: step) { await play() }
    }

    @ViewBuilder
    private var content: some View {
        #if os(macOS)
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 24) {
                stage
                pageText
            }
            .padding(.horizontal, 32)
            .padding(.top, 28)
            .padding(.bottom, 28)
            Divider()
            HStack {
                Spacer()
                button
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .frame(width: 460)
        .fixedSize(horizontal: false, vertical: true)
        #else
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                stage
                pageText
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 24)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollEdgeEffectStyle(.soft, for: .bottom)
        .safeAreaBar(edge: .bottom, spacing: 0) {
            button
                .frame(maxWidth: 560)
                .padding(24)
        }
        #endif
    }

    private var stage: some View {
        OnboardingLiquidGlassStage(step: step, phase: phase, features: context.features)
            .accessibilityHidden(true)
    }

    private var pageText: some View {
        OnboardingLiquidGlassPageText(
            step: step,
            features: context.features,
            plannedSteps: context.plannedSteps
        )
    }

    private var button: some View {
        OnboardingContinueButton(title: context.buttonTitle, action: context.advance)
            .accessibilityIdentifier(context.buttonIdentifier)
    }

    private func play() async {
        let script = OnboardingLiquidGlassScript(step: step)
        guard !reducesMotion else {
            phase = script.finalPhase
            return
        }
        do {
            try await Task.sleep(for: .milliseconds(900))
            while true {
                for beat in script.beats {
                    withAnimation(beat.animation) { phase = beat.phase }
                    try await Task.sleep(for: beat.hold)
                }
            }
        } catch {
            return
        }
    }
}
