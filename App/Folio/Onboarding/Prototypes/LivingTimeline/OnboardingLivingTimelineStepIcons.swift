import SwiftUI

struct OnboardingLivingTimelineStepIcons: View {
    let context: OnboardingPrototypeContext

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(context.plannedSteps.enumerated()), id: \.element) { index, setupStep in
                if index > 0 {
                    connector(isFilled: context.completedSteps.contains(setupStep)
                        || context.currentSetupStep == setupStep)
                }
                icon(for: setupStep)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.spring(duration: 0.5, bounce: 0.3), value: context.step)
        .accessibilityHidden(true)
    }

    private func icon(for setupStep: OnboardingSetupStep) -> some View {
        let isCurrent = context.currentSetupStep == setupStep
        let isCompleted = context.completedSteps.contains(setupStep)
        return Image(systemName: setupStep.livingTimelineSymbol)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(isCurrent ? AnyShapeStyle(.white) : isCompleted
                ? AnyShapeStyle(setupStep.livingTimelineTint) : AnyShapeStyle(.tertiary))
            .frame(width: 28, height: 28)
            .background {
                Circle().fill(isCurrent ? AnyShapeStyle(setupStep.livingTimelineTint.gradient)
                    : isCompleted ? AnyShapeStyle(setupStep.livingTimelineTint.opacity(0.16))
                    : AnyShapeStyle(.quaternary.opacity(0.6)))
            }
            .scaleEffect(isCurrent ? 1.18 : 1)
    }

    private func connector(isFilled: Bool) -> some View {
        Capsule()
            .fill(.quaternary)
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(Color.accentColor.opacity(0.6))
                    .scaleEffect(x: isFilled ? 1 : 0, anchor: .leading)
            }
            .frame(width: 14, height: 3)
    }
}

extension OnboardingSetupStep {
    var livingTimelineSymbol: String {
        switch self {
        case .calendar: "calendar"
        case .reminders: "checklist"
        case .alerts: "bell.fill"
        case .weather: "cloud.sun.fill"
        case .sleep: "moon.fill"
        }
    }

    var livingTimelineTint: Color {
        switch self {
        case .calendar: .blue
        case .reminders: .orange
        case .alerts: .red
        case .weather: .cyan
        case .sleep: .indigo
        }
    }
}
