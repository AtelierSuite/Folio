import SwiftUI

struct OnboardingColorFieldsPalette: Equatable {
    let base: Color
    let partner: Color

    init(step: OnboardingStep) {
        switch step {
        case .welcome:
            base = .accentColor
            partner = Color(red: 0.36, green: 0.12, blue: 0.42)
        case .setup(.calendar):
            base = Color(red: 0.93, green: 0.22, blue: 0.24)
            partner = Color(red: 0.86, green: 0.12, blue: 0.42)
        case .setup(.reminders):
            base = Color(red: 0.98, green: 0.52, blue: 0.10)
            partner = Color(red: 0.96, green: 0.34, blue: 0.16)
        case .setup(.alerts), .setup(.alarms):
            base = Color(red: 0.98, green: 0.40, blue: 0.42)
            partner = Color(red: 0.90, green: 0.26, blue: 0.56)
        case .setup(.weather):
            base = Color(red: 0.18, green: 0.58, blue: 0.95)
            partner = Color(red: 0.16, green: 0.76, blue: 0.92)
        case .setup(.sleep):
            base = Color(red: 0.24, green: 0.20, blue: 0.62)
            partner = Color(red: 0.12, green: 0.10, blue: 0.36)
        }
    }

    func meshColors(deepened: Bool) -> [Color] {
        let depth = deepened ? 0.28 : 0
        let base = base.mix(with: .black, by: depth)
        let partner = partner.mix(with: .black, by: depth)
        let highlight = base.mix(with: .white, by: deepened ? 0.08 : 0.18)
        let shade = partner.mix(with: .black, by: 0.18)
        return [
            highlight, base, partner,
            base, highlight, base,
            partner, base, shade
        ]
    }

    func buttonLabelColor(deepened: Bool) -> Color {
        base.mix(with: .black, by: deepened ? 0.38 : 0.12)
    }
}
