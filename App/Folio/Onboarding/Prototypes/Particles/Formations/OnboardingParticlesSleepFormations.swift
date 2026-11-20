import SwiftUI

nonisolated enum OnboardingParticlesSleepFormations {
    typealias Geometry = OnboardingParticlesGeometry
    typealias Formation = OnboardingParticlesFormation

    static let palette: [Color] = [.teal, .indigo, .orange, .pink]
    private static let driftingStarCount = 100
    private static let stayingStarCount = 22
    private static let moonCenter = CGPoint(x: 0.3, y: -0.2)

    static let night = Formation(
        palette: palette,
        groups: [stars(count: driftingStarCount, seed: 0), moon, stars(count: stayingStarCount, seed: 900)]
    )

    static let asleep = Formation(palette: palette, groups: [band, moon, stars(count: stayingStarCount, seed: 900)])

    private static var moon: [OnboardingParticlesTarget] {
        let crescent = Geometry.disc(center: moonCenter, radius: 0.17, count: 90).filter { point in
            !Geometry.isInside(point, circleAt: CGPoint(x: moonCenter.x + 0.08, y: moonCenter.y - 0.06), radius: 0.14)
        }
        return Formation.group(crescent, radius: 2.5) { _ in .color(2) }
    }

    private static func stars(count: Int, seed: Int) -> [OnboardingParticlesTarget] {
        var stars: [OnboardingParticlesTarget] = []
        var index = seed
        while stars.count < count {
            let point = CGPoint(
                x: Geometry.hash(index * 3 + 11) * 1.5 - 0.75,
                y: Geometry.hash(index * 5 + 7) * 0.72 - 0.44
            )
            index += 1
            guard !Geometry.isInside(point, circleAt: moonCenter, radius: 0.22) else { continue }
            stars.append(OnboardingParticlesTarget(
                position: point,
                radius: 1.4 + Geometry.hash(index * 7) * 1.5,
                opacity: 1,
                ink: .blend(0, 1, Geometry.hash(index * 13)),
                motion: .twinkle,
                parameter: Geometry.hash(index * 19 + 3)
            ))
        }
        return stars
    }

    private static var band: [OnboardingParticlesTarget] {
        let stages: [(level: Int, length: Double)] = [
            (0, 0.04), (2, 0.1), (3, 0.12), (2, 0.08), (1, 0.06), (2, 0.1), (3, 0.06), (2, 0.08), (1, 0.1), (0, 0.04)
        ]
        let levels = [0.04, 0.11, 0.18, 0.25]
        let spacing = 0.018
        var xPosition = -0.54
        var previousLevel: Int?
        var targets: [OnboardingParticlesTarget] = []
        for stage in stages {
            let yPosition = levels[stage.level]
            let ink: OnboardingParticlesInk = stage.level == 0 ? .color(2) : .blend(0, 1, Double(stage.level - 1) / 2)
            if let previousLevel, previousLevel != stage.level {
                let connector = Geometry.line(
                    from: CGPoint(x: xPosition, y: levels[previousLevel]),
                    to: CGPoint(x: xPosition, y: yPosition),
                    count: abs(stage.level - previousLevel) * 3 + 1
                ).dropFirst().dropLast()
                targets += Formation.group(Array(connector), radius: 1.6, opacity: 0.5) { _ in ink }
            }
            let points = Geometry.line(
                from: CGPoint(x: xPosition, y: yPosition),
                to: CGPoint(x: xPosition + stage.length, y: yPosition),
                count: Int((stage.length / spacing).rounded()) + 1
            )
            targets += Formation.group(points, radius: 2.7) { _ in ink }
            xPosition += stage.length
            previousLevel = stage.level
        }
        let event = [-0.013, 0.013].flatMap { offset in
            Geometry.line(from: CGPoint(x: 0.32, y: 0.04 + offset), to: CGPoint(x: 0.52, y: 0.04 + offset), count: 11)
        }
        targets += Formation.group(event, radius: 2.7) { _ in .color(3) }
        return targets + Formation.dust(count: max(driftingStarCount - targets.count, 0), startingAt: 700)
    }
}
