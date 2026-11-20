import SwiftUI

enum OnboardingCarouselPage: Hashable, Identifiable {
    case welcome
    case setup(OnboardingSetupStep)

    var id: String {
        switch self {
        case .welcome: "welcome"
        case .setup(let setupStep): setupStep.rawValue
        }
    }

    var colors: [Color] {
        switch self {
        case .welcome: [.accentColor, .accentColor]
        case .setup(.calendar): [.pink, .red]
        case .setup(.reminders): [.yellow, .orange]
        case .setup(.alerts): [.orange, .red]
        case .setup(.weather): [.cyan, .blue]
        case .setup(.sleep): [.purple, .indigo]
        }
    }

    var tint: Color { colors.last ?? .accentColor }
}
