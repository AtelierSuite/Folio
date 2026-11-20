import SwiftUI

nonisolated enum OnboardingParticlesAlertsFormations {
    typealias Geometry = OnboardingParticlesGeometry
    typealias Formation = OnboardingParticlesFormation

    static let palette: [Color] = [.red, .orange]
    private static let pivot = CGPoint(x: 0, y: -0.38)
    private static let waveCenter = CGPoint(x: 0, y: -0.04)
    private static let waveOffsets = [0.0, 1.0 / 3, 2.0 / 3]
    private static let wavePointCount = 9

    static let gathered = Formation(palette: palette, groups: [bell(motion: .still)])

    static let ringing = Formation(palette: palette, groups: [bell(motion: .swing(pivot: pivot))] + waves)

    private static func bell(motion: OnboardingParticlesMotion) -> [OnboardingParticlesTarget] {
        let knob = Geometry.ring(center: CGPoint(x: 0, y: -0.36), radius: 0.03, count: 6)
        let dome = Geometry.arc(center: CGPoint(x: 0, y: -0.14), radius: 0.17, from: .pi, to: .pi * 2, count: 17)
        let leftSide = Geometry.curve(
            from: CGPoint(x: -0.17, y: -0.12),
            control: CGPoint(x: -0.17, y: 0.08),
            to: CGPoint(x: -0.27, y: 0.16),
            count: 9
        )
        let rightSide = leftSide.map { CGPoint(x: -$0.x, y: $0.y) }
        let rim = Geometry.line(from: CGPoint(x: -0.29, y: 0.18), to: CGPoint(x: 0.29, y: 0.18), count: 15)
        let clapper = Geometry.disc(center: CGPoint(x: 0, y: 0.26), radius: 0.035, count: 5)
        return Formation.group(knob + dome + leftSide + rightSide + rim + clapper, motion: motion) {
            Formation.vertical($0, top: -0.38, bottom: 0.28)
        }
    }

    private static var waves: [[OnboardingParticlesTarget]] {
        waveOffsets.flatMap { offset in
            [0.0, Double.pi].map { side in
                (0..<wavePointCount).map { index in
                    OnboardingParticlesTarget(
                        position: waveCenter,
                        radius: 2.6,
                        opacity: 1,
                        ink: .blend(0, 1, 0.6),
                        motion: .wave(offset: offset),
                        parameter: side + (Double(index) / Double(wavePointCount - 1) - 0.5) * 0.95
                    )
                }
            }
        }
    }
}
