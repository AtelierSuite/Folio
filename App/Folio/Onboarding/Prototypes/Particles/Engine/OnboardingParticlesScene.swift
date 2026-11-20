import SwiftUI

struct OnboardingParticlesScene {
    struct Phase {
        let formation: OnboardingParticlesFormation
        let duration: Double
    }

    let identifier: String
    let phases: [Phase]
    let loopStart: Int
    let stillPhase: Int

    var tint: Color { phases[stillPhase].formation.palette.first ?? .accentColor }
}

extension OnboardingParticlesScene {
    private static var welcomeCache: [[OnboardingFeature]: OnboardingParticlesScene] = [:]

    static func scene(for step: OnboardingStep, features: [OnboardingFeature]) -> OnboardingParticlesScene {
        switch step {
        case .welcome: welcome(features: features)
        case .setup(let setupStep): setup(setupStep)
        }
    }

    private static func welcome(features: [OnboardingFeature]) -> OnboardingParticlesScene {
        if let cached = welcomeCache[features] { return cached }
        typealias Welcome = OnboardingParticlesWelcomeFormations
        let scene = OnboardingParticlesScene(
            identifier: "welcome",
            phases: [Phase(formation: Welcome.swirl(features: features), duration: 1.8),
                     Phase(formation: Welcome.arrangement(features: features), duration: 2.8)]
                + features.map { Phase(formation: Welcome.symbol($0), duration: 2.3) },
            loopStart: 1,
            stillPhase: 1
        )
        welcomeCache[features] = scene
        return scene
    }

    private static func setup(_ step: OnboardingSetupStep) -> OnboardingParticlesScene {
        let phases: [Phase]
        var loopStart = 0
        switch step {
        case .calendar:
            phases = [Phase(formation: OnboardingParticlesCalendarFormations.month, duration: 1.4),
                      Phase(formation: OnboardingParticlesCalendarFormations.scheduled, duration: .infinity)]
        case .reminders:
            let ticking = OnboardingParticlesRemindersFormations.ticking
            phases = [Phase(formation: ticking[0], duration: 1.5),
                      Phase(formation: ticking[1], duration: 0.9),
                      Phase(formation: ticking[2], duration: 0.9),
                      Phase(formation: ticking[3], duration: 2.6)]
            loopStart = 0
        case .alerts, .alarms:
            phases = [Phase(formation: OnboardingParticlesAlertsFormations.gathered, duration: 1.1),
                      Phase(formation: OnboardingParticlesAlertsFormations.ringing, duration: .infinity)]
        case .weather:
            phases = [Phase(formation: OnboardingParticlesWeatherFormations.clouded, duration: 1.1),
                      Phase(formation: OnboardingParticlesWeatherFormations.raining, duration: .infinity)]
        case .sleep:
            phases = [Phase(formation: OnboardingParticlesSleepFormations.night, duration: 2.4),
                      Phase(formation: OnboardingParticlesSleepFormations.asleep, duration: .infinity)]
        }
        return OnboardingParticlesScene(
            identifier: step.rawValue,
            phases: phases,
            loopStart: loopStart,
            stillPhase: phases.count - 1
        )
    }

    func phaseIndex(at elapsed: Double) -> Int {
        var remaining = elapsed
        for index in phases.indices {
            if remaining < phases[index].duration { return index }
            remaining -= phases[index].duration
        }
        let loopDuration = phases[loopStart...].reduce(0) { $0 + $1.duration }
        guard loopDuration > 0, loopDuration.isFinite else { return phases.count - 1 }
        remaining = remaining.truncatingRemainder(dividingBy: loopDuration)
        for index in loopStart..<phases.count {
            if remaining < phases[index].duration { return index }
            remaining -= phases[index].duration
        }
        return phases.count - 1
    }
}
