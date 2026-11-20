import SwiftUI

struct OnboardingLiquidGlassBeat {
    let phase: Int
    let hold: Duration
    let animation: Animation
}

struct OnboardingLiquidGlassScript {
    let step: OnboardingStep

    var backdropColors: [Color] {
        switch step {
        case .welcome: [.pink, .teal, .yellow, .cyan]
        case .setup(.calendar): [.red, .blue, .orange, .pink]
        case .setup(.reminders): [.orange, .teal, .yellow, .green]
        case .setup(.alerts): [.orange, .red, .pink, .yellow]
        case .setup(.weather): [.cyan, .blue, .yellow, .teal]
        case .setup(.sleep): [.indigo, .purple, .teal, .blue]
        }
    }

    var finalPhase: Int {
        switch step {
        case .welcome: 0
        case .setup(.calendar): 4
        case .setup(.reminders): 3
        case .setup(.alerts): 1
        case .setup(.weather): 5
        case .setup(.sleep): 1
        }
    }

    var beats: [OnboardingLiquidGlassBeat] {
        switch step {
        case .welcome:
            let blob = Animation.bouncy(duration: 0.9, extraBounce: 0.15)
            return [1, 2, 1, 0].map { phase in
                OnboardingLiquidGlassBeat(phase: phase, hold: .milliseconds(1700), animation: blob)
            }
        case .setup(.alerts):
            return [
                OnboardingLiquidGlassBeat(
                    phase: 1,
                    hold: .seconds(3),
                    animation: .bouncy(duration: 0.7, extraBounce: 0.1)
                ),
                OnboardingLiquidGlassBeat(phase: 0, hold: .milliseconds(1200), animation: .smooth(duration: 0.5))
            ]
        case .setup(.sleep):
            return [
                OnboardingLiquidGlassBeat(phase: 1, hold: .milliseconds(3400), animation: .smooth(duration: 1.8)),
                OnboardingLiquidGlassBeat(phase: 0, hold: .milliseconds(1400), animation: .smooth(duration: 0.8))
            ]
        case .setup(.calendar), .setup(.reminders), .setup(.weather):
            return sequence(through: finalPhase)
        }
    }

    private func sequence(through lastPhase: Int) -> [OnboardingLiquidGlassBeat] {
        let landing = Animation.spring(duration: 0.7, bounce: 0.3)
        let steps = (1...lastPhase).map { phase in
            OnboardingLiquidGlassBeat(
                phase: phase,
                hold: phase == lastPhase ? .milliseconds(2600) : .milliseconds(550),
                animation: landing
            )
        }
        let reset = OnboardingLiquidGlassBeat(phase: 0, hold: .milliseconds(1100), animation: .smooth(duration: 0.6))
        return steps + [reset]
    }
}
