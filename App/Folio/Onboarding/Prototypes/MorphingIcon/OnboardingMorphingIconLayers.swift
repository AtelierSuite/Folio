import SwiftUI

struct OnboardingMorphingIconBackLayer: View {
    let step: OnboardingStep
    let beat: Int
    let unit: CGFloat
    let features: [OnboardingFeature]
    let highlightedFeature: OnboardingFeature?

    var body: some View {
        Group {
            switch step {
            case .welcome:
                OnboardingMorphingIconWelcomeOrbit(
                    features: features, highlightedFeature: highlightedFeature, unit: unit
                )
            case .setup(.calendar):
                OnboardingMorphingIconCalendarTrack(unit: unit)
            case .setup(.reminders):
                OnboardingMorphingIconReminderRing(beat: beat, unit: unit)
            case .setup(.alerts):
                OnboardingMorphingIconAlertBurst(beat: beat, unit: unit)
            case .setup(.weather):
                OnboardingMorphingIconWeatherSky(unit: unit)
            case .setup(.sleep):
                OnboardingMorphingIconNightSky(unit: unit)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.scale(scale: 0.3).combined(with: .opacity))
    }
}

struct OnboardingMorphingIconFrontLayer: View {
    let step: OnboardingStep
    let beat: Int
    let unit: CGFloat

    var body: some View {
        Group {
            switch step {
            case .setup(.calendar):
                OnboardingMorphingIconCalendarOrbit(beat: beat, unit: unit)
            case .setup(.weather):
                OnboardingMorphingIconWeatherClouds(unit: unit)
            default:
                Color.clear
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
        .transition(.scale(scale: 0.3).combined(with: .opacity))
    }
}
