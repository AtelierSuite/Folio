import SwiftUI

nonisolated enum OnboardingParticlesWeatherFormations {
    typealias Geometry = OnboardingParticlesGeometry
    typealias Formation = OnboardingParticlesFormation

    static let palette: [Color] = [.cyan, .blue, .yellow, .orange]
    private static let rainCount = 40

    static let clouded = Formation(palette: palette, groups: [sun, cloud])

    static let raining = Formation(palette: palette, groups: [sun, cloud, rain])

    private static var sun: [OnboardingParticlesTarget] {
        let center = CGPoint(x: 0.2, y: -0.2)
        let disc = Geometry.disc(center: center, radius: 0.13, count: 30)
        let rays = Geometry.ring(center: center, radius: 0.2, count: 12)
        return Formation.group(disc, radius: 2.8, motion: .pulse) { .blend(2, 3, ($0.y + 0.33) / 0.26) }
            + Formation.group(rays, radius: 2, motion: .twinkle) { _ in .color(2) }
    }

    private static var cloud: [OnboardingParticlesTarget] {
        let circles: [(center: CGPoint, radius: Double)] = [
            (CGPoint(x: -0.24, y: 0.0), 0.1),
            (CGPoint(x: -0.08, y: -0.08), 0.15),
            (CGPoint(x: 0.09, y: -0.01), 0.11)
        ]
        let bounds = CGRect(x: -0.36, y: -0.24, width: 0.58, height: 0.36)
        let points = Geometry.filled(spacing: 0.046, within: bounds) { point in
            let inCircle = circles.contains { Geometry.isInside(point, circleAt: $0.center, radius: $0.radius) }
            let inBase = Geometry.distance(
                from: point,
                toSegmentFrom: CGPoint(x: -0.25, y: 0.05),
                to: CGPoint(x: 0.1, y: 0.05)
            ) <= 0.06
            return inCircle || inBase
        }
        return Formation.group(points, radius: 2.7, opacity: 0.55) { _ in .neutral }
    }

    private static var rain: [OnboardingParticlesTarget] {
        (0..<rainCount).map { index in
            OnboardingParticlesTarget(
                position: CGPoint(x: -0.32 + Geometry.hash(index * 5 + 3) * 0.44, y: 0.1),
                radius: 1.8,
                opacity: 0.95,
                ink: .blend(0, 1, Geometry.hash(index * 9 + 1)),
                motion: .rain,
                parameter: Geometry.hash(index * 17 + 4)
            )
        }
    }
}
