import SwiftUI

struct OnboardingFinalTimeline: View {
    @State private var nowHour = OnboardingFinalNowLineSlot.restingHour
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
                layer(.calendar, width: proxy.size.width) {
                    OnboardingFinalEventsLayer(
                        geometry: geometry,
                        source: $1,
                        state: $0,
                        isSharingRow: state(for: .reminders).isShown
                    )
                }
                layer(.reminders, width: proxy.size.width) {
                    OnboardingFinalRemindersLayer(
                        geometry: geometry,
                        source: $1,
                        state: $0,
                        isSharingRow: state(for: .calendar).isShown
                    )
                }
                layer(.weather, width: proxy.size.width) {
                    OnboardingFinalWeatherLayer(geometry: geometry, source: $1, state: $0)
                }
                layer(.alarms, width: proxy.size.width) {
                    OnboardingFinalAlarmsLayer(geometry: geometry, source: $1, state: $0)
                }
                OnboardingFinalNowLineSlot(geometry: geometry, hour: nowHour)
                layer(.alerts, width: proxy.size.width) {
                    OnboardingFinalAlertsLayer(geometry: geometry, source: $1, state: $0, nowHour: $nowHour)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
        }
        .frame(height: context.step == .welcome ? Metrics.welcomeHeight : Metrics.height)
        .animation(.spring(duration: 0.7, bounce: 0.2), value: context.step == .welcome)
        .background(shape.fill(.white.opacity(0.12)))
        .overlay(shape.strokeBorder(.white.opacity(0.3), lineWidth: 1))
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func layer(
        _ setupStep: OnboardingSetupStep,
        width: CGFloat,
        @ViewBuilder content: (OnboardingFinalLayerState, CGPoint) -> some View
    ) -> some View {
        let state = state(for: setupStep)
        if state != .hidden {
            let source = OnboardingFinalTrailLayout.badgeCenter(
                for: setupStep,
                in: context.plannedSteps,
                width: width
            ) ?? CGPoint(x: width / 2, y: 0)
            content(state, source)
                .transition(.identity)
        }
    }

    private func state(for setupStep: OnboardingSetupStep) -> OnboardingFinalLayerState {
        guard context.plannedSteps.contains(setupStep) else { return .hidden }
        if context.currentSetupStep == setupStep { return .current }
        guard context.completedSteps.contains(setupStep) else { return .hidden }
        return context.declinedSteps.contains(setupStep) ? .declined : .completed
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
    }
}
