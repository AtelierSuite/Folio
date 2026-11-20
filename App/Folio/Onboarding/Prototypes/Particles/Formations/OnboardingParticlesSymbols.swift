import SwiftUI

nonisolated enum OnboardingParticlesSymbols {
    typealias Geometry = OnboardingParticlesGeometry

    static func targets(for feature: OnboardingFeature, colorIndex: Int) -> [OnboardingParticlesTarget] {
        let tint: (CGPoint) -> OnboardingParticlesInk = { point in
            .blend(colorIndex, colorIndex + 1, min(max((point.y + 0.4) / 0.8, 0), 1))
        }
        switch feature {
        case .calendar: return calendar(tint: tint)
        case .sleep: return moon(tint: tint)
        case .notes: return note(tint: tint)
        case .privacy: return hand(tint: tint)
        }
    }

    private static func calendar(tint: @escaping (CGPoint) -> OnboardingParticlesInk) -> [OnboardingParticlesTarget] {
        let frame = Geometry.roundedRectangle(
            center: CGPoint(x: 0, y: 0.04), width: 0.78, height: 0.68, cornerRadius: 0.1, count: 40
        )
        let header = Geometry.line(from: CGPoint(x: -0.3, y: -0.22), to: CGPoint(x: 0.3, y: -0.22), count: 13)
            + Geometry.line(from: CGPoint(x: -0.28, y: -0.18), to: CGPoint(x: 0.28, y: -0.18), count: 12)
        let binders = Geometry.line(from: CGPoint(x: -0.18, y: -0.4), to: CGPoint(x: -0.18, y: -0.32), count: 3)
            + Geometry.line(from: CGPoint(x: 0.18, y: -0.4), to: CGPoint(x: 0.18, y: -0.32), count: 3)
        let days = Geometry.grid(center: CGPoint(x: 0, y: 0.1), columns: 4, rows: 3, spacingX: 0.15, spacingY: 0.11)
        return OnboardingParticlesFormation.group(frame + header + binders, ink: tint)
            + OnboardingParticlesFormation.group(days, radius: 3, ink: tint)
    }

    private static func moon(tint: @escaping (CGPoint) -> OnboardingParticlesInk) -> [OnboardingParticlesTarget] {
        let crescent = Geometry.disc(center: .zero, radius: 0.37, count: 190).filter { point in
            !Geometry.isInside(point, circleAt: CGPoint(x: 0.17, y: -0.11), radius: 0.31)
        }
        let stars = [CGPoint(x: 0.3, y: 0.18), CGPoint(x: 0.4, y: 0.02), CGPoint(x: 0.22, y: 0.3)]
        return OnboardingParticlesFormation.group(crescent, ink: tint)
            + OnboardingParticlesFormation.group(stars, radius: 2.2, motion: .twinkle, ink: tint)
    }

    private static func note(tint: @escaping (CGPoint) -> OnboardingParticlesInk) -> [OnboardingParticlesTarget] {
        let page = Geometry.roundedRectangle(center: .zero, width: 0.62, height: 0.8, cornerRadius: 0.08, count: 42)
        let lengths = [0.4, 0.4, 0.4, 0.28, 0.34]
        let lines = lengths.enumerated().flatMap { index, length in
            let yPosition = -0.24 + Double(index) * 0.12
            return Geometry.line(
                from: CGPoint(x: -0.2, y: yPosition),
                to: CGPoint(x: -0.2 + length, y: yPosition),
                count: Int(length / 0.045) + 1
            )
        }
        return OnboardingParticlesFormation.group(page, ink: tint)
            + OnboardingParticlesFormation.group(lines, radius: 2.3, opacity: 0.7) { _ in .neutral }
    }

    private static func hand(tint: @escaping (CGPoint) -> OnboardingParticlesInk) -> [OnboardingParticlesTarget] {
        let fingers: [(xPosition: Double, top: Double)] = [
            (-0.135, -0.27), (-0.045, -0.38), (0.045, -0.36), (0.135, -0.25)
        ]
        let bounds = CGRect(x: -0.36, y: -0.42, width: 0.56, height: 0.8)
        let points = Geometry.filled(spacing: 0.047, within: bounds) { point in
            let palm = Geometry.distance(
                from: point,
                toSegmentFrom: CGPoint(x: -0.04, y: 0.13),
                to: CGPoint(x: 0.04, y: 0.13)
            ) <= 0.16 && point.y >= -0.02
            let finger = fingers.contains { finger in
                Geometry.distance(
                    from: point,
                    toSegmentFrom: CGPoint(x: finger.xPosition, y: finger.top),
                    to: CGPoint(x: finger.xPosition, y: 0.05)
                ) <= 0.036
            }
            let thumb = Geometry.distance(
                from: point,
                toSegmentFrom: CGPoint(x: -0.16, y: 0.14),
                to: CGPoint(x: -0.3, y: -0.03)
            ) <= 0.04
            return palm || finger || thumb
        }
        return OnboardingParticlesFormation.group(points, ink: tint)
    }
}
