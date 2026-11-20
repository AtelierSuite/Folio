import SwiftUI

struct OnboardingMorphingIconFace: Equatable {
    let symbol: String
    let colors: [Color]

    static let folio = OnboardingMorphingIconFace(
        symbol: "book.pages.fill",
        colors: [
            Color.accentColor.mix(with: .white, by: 0.2),
            Color.accentColor.mix(with: .black, by: 0.3)
        ]
    )

    init(symbol: String, colors: [Color]) {
        self.symbol = symbol
        self.colors = colors
    }

    init(feature: OnboardingFeature) {
        self.init(symbol: feature.systemImage, colors: feature.gradientColors)
    }

    init(step: OnboardingSetupStep) {
        switch step {
        case .calendar:
            self.init(symbol: "calendar", colors: [
                Color(red: 1.0, green: 0.45, blue: 0.45), Color(red: 0.86, green: 0.14, blue: 0.27)
            ])
        case .reminders:
            self.init(symbol: "checklist", colors: [
                Color(red: 0.38, green: 0.86, blue: 0.62), Color(red: 0.08, green: 0.58, blue: 0.44)
            ])
        case .alerts, .alarms:
            self.init(symbol: "bell.badge.fill", colors: [
                Color(red: 1.0, green: 0.72, blue: 0.26), Color(red: 0.95, green: 0.36, blue: 0.15)
            ])
        case .weather:
            self.init(symbol: "cloud.sun.fill", colors: [
                Color(red: 0.42, green: 0.8, blue: 1.0), Color(red: 0.14, green: 0.44, blue: 0.9)
            ])
        case .sleep:
            self.init(symbol: "bed.double.fill", colors: [
                Color(red: 0.25, green: 0.26, blue: 0.52), Color(red: 0.05, green: 0.06, blue: 0.19)
            ])
        }
    }
}
