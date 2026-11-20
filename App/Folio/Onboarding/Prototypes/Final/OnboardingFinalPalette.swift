import SwiftUI

enum OnboardingFinalPalette {
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
        base(for: .setup(step))
    }

    static func meshColors(for step: OnboardingStep, deepened: Bool) -> [Color] {
        let depth = deepened ? 0.28 : 0
        let base = base(for: step).mix(with: .black, by: depth)
        let partner = partner(for: step).mix(with: .black, by: depth)
        let highlight = base.mix(with: .white, by: deepened ? 0.08 : 0.18)
        let shade = partner.mix(with: .black, by: 0.18)
        return [
            highlight, base, partner,
            base, highlight, base,
            partner, base, shade
        ]
    }

    private static func base(for step: OnboardingStep) -> Color {
        switch step {
        case .welcome: .accentColor
        case .setup(.calendar): Color(red: 0.93, green: 0.22, blue: 0.24)
        case .setup(.reminders): Color(red: 0.98, green: 0.52, blue: 0.10)
        case .setup(.alerts): Color(red: 0.98, green: 0.40, blue: 0.42)
        case .setup(.weather): Color(red: 0.18, green: 0.58, blue: 0.95)
        case .setup(.sleep): Color(red: 0.24, green: 0.20, blue: 0.62)
        }
    }

    private static func partner(for step: OnboardingStep) -> Color {
        switch step {
        case .welcome: Color(red: 0.36, green: 0.12, blue: 0.42)
        case .setup(.calendar): Color(red: 0.86, green: 0.12, blue: 0.42)
        case .setup(.reminders): Color(red: 0.96, green: 0.34, blue: 0.16)
        case .setup(.alerts): Color(red: 0.90, green: 0.26, blue: 0.56)
        case .setup(.weather): Color(red: 0.16, green: 0.76, blue: 0.92)
        case .setup(.sleep): Color(red: 0.12, green: 0.10, blue: 0.36)
        }
    }
}
