import CoreGraphics
import Foundation

nonisolated extension OnboardingParticlesTarget {
    func frame(at time: Double) -> OnboardingParticlesFrame {
        var frame = OnboardingParticlesFrame(position: position, radius: radius, opacity: opacity)
        switch motion {
        case .still:
            break
        case .drift:
            frame.position.x += sin(time * 0.6 + parameter * 6.28) * 0.006
            frame.position.y += cos(time * 0.5 + parameter * 9.1) * 0.006
        case .twinkle:
            let shimmer = 0.5 + 0.5 * sin(time * (1.1 + parameter * 1.6) + parameter * 20)
            frame.opacity *= 0.35 + 0.65 * shimmer
            frame.radius *= 0.8 + 0.35 * shimmer
        case .pulse:
            frame.radius *= 1 + 0.2 * sin(time * 2.4 + parameter * 3)
        case .rain:
            let fall = (time * 0.7 + parameter).truncatingRemainder(dividingBy: 1)
            frame.position.y += fall * 0.36
            frame.position.x -= fall * 0.05
            frame.opacity *= min(fall / 0.12, 1) * min((1 - fall) / 0.35, 1)
            frame.stretch = 2.8
        case .wave(let offset):
            let spread = (time * 0.45 + offset).truncatingRemainder(dividingBy: 1)
            let distance = 0.3 + spread * 0.42
            frame.position.x += cos(parameter) * distance
            frame.position.y += sin(parameter) * distance
            frame.opacity *= (1 - spread) * min(spread / 0.15, 1)
        case .swirl:
            let distance = hypot(position.x, position.y)
            let angle = atan2(position.y, position.x) + time * (0.5 / (0.2 + distance))
            frame.position = CGPoint(x: cos(angle) * distance, y: sin(angle) * distance)
        case .swing(let pivot):
            let ringing = pow(max(0, sin(time * 1.45)), 6)
            let angle = 0.2 * sin(time * 16) * ringing
            let relativeX = position.x - pivot.x
            let relativeY = position.y - pivot.y
            frame.position.x = pivot.x + relativeX * cos(angle) - relativeY * sin(angle)
            frame.position.y = pivot.y + relativeX * sin(angle) + relativeY * cos(angle)
        }
        return frame
    }
}
