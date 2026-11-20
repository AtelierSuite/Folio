import SwiftUI

nonisolated enum OnboardingParticlesInk: Sendable {
    case neutral
    case color(Int)
    case blend(Int, Int, Double)
}

nonisolated enum OnboardingParticlesMotion: Sendable {
    case still
    case drift
    case twinkle
    case pulse
    case rain
    case wave(offset: Double)
    case swirl
    case swing(pivot: CGPoint)
}

nonisolated struct OnboardingParticlesTarget: Sendable {
    var position: CGPoint
    var radius: CGFloat
    var opacity: Double
    var ink: OnboardingParticlesInk
    var motion: OnboardingParticlesMotion
    var parameter: Double = 0
}

nonisolated struct OnboardingParticlesFrame {
    var position: CGPoint
    var radius: CGFloat
    var opacity: Double
    var stretch: CGFloat = 1
}
