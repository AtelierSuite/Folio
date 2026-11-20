import SwiftUI

enum OnboardingJourneyPalette {
    static func symbol(for step: OnboardingSetupStep) -> String {
        switch step {
        case .calendar: "calendar"
        case .reminders: "checklist"
        case .alerts: "bell.fill"
        case .weather: "cloud.sun.fill"
        case .sleep: "bed.double.fill"
        }
    }

    static func tint(for step: OnboardingSetupStep) -> Color {
        colors(for: step)[1]
    }

    static func colors(for step: OnboardingSetupStep) -> [Color] {
        switch step {
        case .calendar: [.pink, .red]
        case .reminders: [.mint, .green]
        case .alerts: [.yellow, .orange]
        case .weather: [.cyan, .blue]
        case .sleep: [.purple, .indigo]
        }
    }

    static func gradient(for step: OnboardingSetupStep) -> LinearGradient {
        LinearGradient(colors: colors(for: step), startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func pathGradient(for steps: [OnboardingSetupStep], axis: Axis) -> LinearGradient {
        let colors = steps.isEmpty ? [Color.accentColor] : steps.map(tint)
        return LinearGradient(
            colors: colors,
            startPoint: axis == .vertical ? .top : .leading,
            endPoint: axis == .vertical ? .bottom : .trailing
        )
    }
}
