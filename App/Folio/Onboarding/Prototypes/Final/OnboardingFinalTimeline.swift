import SwiftUI

struct OnboardingFinalTimeline: View {
    let context: OnboardingPrototypeContext

    var body: some View {
        GeometryReader { proxy in
            let geometry = OnboardingFinalTimelineGeometry(
                size: proxy.size,
                gutterWidth: Metrics.gutterWidth,
                verticalInset: Metrics.verticalInset
            )
            ZStack(alignment: .topLeading) {
                OnboardingFinalTimelineGrid(geometry: geometry)
                GlassEffectContainer(spacing: Metrics.glassSpacing) {
                    ZStack(alignment: .topLeading) {
                        layer(.calendar) { OnboardingFinalEventsLayer(geometry: geometry, state: $0) }
                        layer(.reminders) { OnboardingFinalRemindersLayer(geometry: geometry, state: $0) }
                        layer(.weather) { OnboardingFinalWeatherLayer(geometry: geometry, state: $0) }
                        layer(.alerts) { OnboardingFinalAlertsLayer(geometry: geometry, state: $0) }
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
        }
        .frame(height: context.step == .welcome ? Metrics.welcomeHeight : Metrics.height)
        .animation(.spring(duration: 0.7, bounce: 0.2), value: context.step == .welcome)
        .background(shape.fill(.white.opacity(0.12)))
        .overlay(shape.strokeBorder(.white.opacity(0.3), lineWidth: 1))
        .clipShape(shape)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func layer(
        _ setupStep: OnboardingSetupStep,
        @ViewBuilder content: (OnboardingFinalLayerState) -> some View
    ) -> some View {
        let state = state(for: setupStep)
        if state != .hidden {
            content(state)
                .transition(.identity)
        }
    }

    private func state(for setupStep: OnboardingSetupStep) -> OnboardingFinalLayerState {
        guard context.plannedSteps.contains(setupStep) else { return .hidden }
        if context.currentSetupStep == setupStep { return .current }
        return context.completedSteps.contains(setupStep) ? .completed : .hidden
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Metrics.cornerRadius)
    }

    private enum Metrics {
        #if os(macOS)
        static let height: CGFloat = 230
        static let welcomeHeight: CGFloat = 150
        static let cornerRadius: CGFloat = 20
        static let gutterWidth: CGFloat = 46
        static let verticalInset: CGFloat = 6
        #else
        static let height: CGFloat = 300
        static let welcomeHeight: CGFloat = 190
        static let cornerRadius: CGFloat = 30
        static let gutterWidth: CGFloat = 52
        static let verticalInset: CGFloat = 10
        #endif
        static let glassSpacing: CGFloat = 12
    }
}
