import SwiftUI

nonisolated struct OnboardingParticlesFormation: Sendable {
    static let particleCount = 180

    let palette: [Color]
    let targets: [OnboardingParticlesTarget]

    init(palette: [Color], groups: [[OnboardingParticlesTarget]]) {
        self.palette = palette
        var targets = Array(groups.joined().prefix(Self.particleCount))
        var dustIndex = targets.count
        while targets.count < Self.particleCount {
            targets.append(Self.dust(dustIndex))
            dustIndex += 1
        }
        self.targets = targets
    }

    static func group(
        _ points: [CGPoint],
        radius: CGFloat = 2.6,
        opacity: Double = 1,
        motion: OnboardingParticlesMotion = .still,
        ink: (CGPoint) -> OnboardingParticlesInk
    ) -> [OnboardingParticlesTarget] {
        points.enumerated().map { index, point in
            OnboardingParticlesTarget(
                position: point,
                radius: radius,
                opacity: opacity,
                ink: ink(point),
                motion: motion,
                parameter: OnboardingParticlesGeometry.hash(index + Int(point.x * 997) + Int(point.y * 1999))
            )
        }
    }

    static func vertical(_ point: CGPoint, top: Double = -0.4, bottom: Double = 0.4) -> OnboardingParticlesInk {
        .blend(0, 1, min(max((point.y - top) / (bottom - top), 0), 1))
    }

    static func dust(count: Int, startingAt start: Int) -> [OnboardingParticlesTarget] {
        (start..<start + count).map(dust)
    }

    private static func dust(_ index: Int) -> OnboardingParticlesTarget {
        OnboardingParticlesTarget(
            position: CGPoint(
                x: OnboardingParticlesGeometry.hash(index * 3 + 1) * 2 - 1,
                y: OnboardingParticlesGeometry.hash(index * 7 + 5) * 0.96 - 0.48
            ),
            radius: 1.2 + OnboardingParticlesGeometry.hash(index * 11) * 0.6,
            opacity: 0.16,
            ink: .neutral,
            motion: .drift,
            parameter: OnboardingParticlesGeometry.hash(index * 13 + 2)
        )
    }
}
