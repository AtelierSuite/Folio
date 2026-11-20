import SwiftUI

struct OnboardingMorphingIconRhythm {
    static let reminderCount = 6
    static let reminderCycle = reminderCount + 3

    let firstDelay: Duration
    let interval: Duration

    init?(step: OnboardingStep) {
        switch step {
        case .setup(.calendar):
            firstDelay = .seconds(0.9)
            interval = .seconds(1.2)
        case .setup(.reminders):
            firstDelay = .seconds(0.7)
            interval = .seconds(0.55)
        case .setup(.alerts), .setup(.alarms):
            firstDelay = .seconds(0.8)
            interval = .seconds(3.6)
        default:
            return nil
        }
    }

    func checksCircle(atBeat beat: Int) -> Bool {
        (1...Self.reminderCount).contains(beat % Self.reminderCycle)
    }

    static func checkedReminders(atBeat beat: Int, reducesMotion: Bool) -> Int {
        reducesMotion ? reminderCount : min(beat % reminderCycle, reminderCount)
    }
}
