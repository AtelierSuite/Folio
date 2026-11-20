import SwiftUI

struct OnboardingLiquidGlassLayout {
    let size: CGSize
    let phase: Int
    let features: [OnboardingFeature]

    var timeline: OnboardingLiquidGlassTimeline { OnboardingLiquidGlassTimeline(size: size) }

    func showsHourGrid(for step: OnboardingStep) -> Bool {
        step == .setup(.calendar) || step == .setup(.alerts)
    }

    func pieces(for step: OnboardingStep) -> [OnboardingLiquidGlassPiece] {
        switch step {
        case .welcome: welcomePieces
        case .setup(.calendar): calendarPieces
        case .setup(.reminders): reminderPieces
        case .setup(.alerts): alertPieces
        case .setup(.weather): weatherPieces
        case .setup(.sleep): sleepPieces
        }
    }
}
