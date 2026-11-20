import SwiftUI

struct OnboardingLivingTimelineCard: View {
    let context: OnboardingPrototypeContext

    var body: some View {
        GeometryReader { proxy in
            let geometry = OnboardingLivingTimelineGeometry(
                size: proxy.size,
                gutterWidth: Metrics.gutterWidth,
                verticalInset: Metrics.verticalInset
            )
            ZStack(alignment: .topLeading) {
                layer(.weather) { OnboardingLivingTimelineWeatherTint(geometry: geometry, state: $0) }
                OnboardingLivingTimelineGrid(geometry: geometry)
                layer(.weather) { OnboardingLivingTimelineWeatherLayer(geometry: geometry, state: $0) }
                layer(.sleep) { OnboardingLivingTimelineSleepLayer(geometry: geometry, state: $0) }
                layer(.calendar) { OnboardingLivingTimelineEventsLayer(geometry: geometry, state: $0) }
                layer(.reminders) { OnboardingLivingTimelineRemindersLayer(geometry: geometry, state: $0) }
                layer(.alerts) { OnboardingLivingTimelineAlertsLayer(geometry: geometry, state: $0) }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
        }
        .frame(height: Metrics.height)
        .clipShape(shape)
        .background {
            shape
                .fill(.background)
                .shadow(color: .black.opacity(0.12), radius: 20, y: 10)
        }
        .overlay { shape.strokeBorder(.quaternary, lineWidth: 1) }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func layer(
        _ setupStep: OnboardingSetupStep,
        @ViewBuilder content: (OnboardingLivingTimelineLayerState) -> some View
    ) -> some View {
        let state = state(for: setupStep)
        if state != .hidden {
            content(state)
                .livingTimelineLayer(state)
                .transition(.identity)
        }
    }

    private func state(for setupStep: OnboardingSetupStep) -> OnboardingLivingTimelineLayerState {
        guard context.plannedSteps.contains(setupStep) else { return .hidden }
        if context.currentSetupStep == setupStep { return .current }
        if context.completedSteps.contains(setupStep) { return .completed }
        return .hidden
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Metrics.cornerRadius)
    }

    private enum Metrics {
        #if os(macOS)
        static let height: CGFloat = 230
        static let cornerRadius: CGFloat = 20
        static let gutterWidth: CGFloat = 46
        static let verticalInset: CGFloat = 6
        #else
        static let height: CGFloat = 300
        static let cornerRadius: CGFloat = 30
        static let gutterWidth: CGFloat = 52
        static let verticalInset: CGFloat = 10
        #endif
    }
}
