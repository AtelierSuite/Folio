import SwiftUI

enum OnboardingParticlesWelcomeFormations {
    typealias Geometry = OnboardingParticlesGeometry
    typealias Formation = OnboardingParticlesFormation

    private static let palette = OnboardingFeature.allCases.flatMap(\.gradientColors)

    static func swirl(features: [OnboardingFeature]) -> Formation {
        let count = Formation.particleCount
        let targets = (0..<count).map { index in
            let fraction = Double(index) / Double(count)
            let arm = Double(index % 3) * 2 * .pi / 3
            let distance = 0.06 + fraction * 0.42 + Geometry.hash(index) * 0.04
            let angle = fraction * 3.6 * .pi + arm + Geometry.hash(index * 3) * 0.4
            let feature = features[index % max(features.count, 1)]
            return OnboardingParticlesTarget(
                position: CGPoint(x: cos(angle) * distance * 1.25, y: sin(angle) * distance * 0.95),
                radius: 1.4 + (1 - fraction) * 1.4,
                opacity: 0.95,
                ink: .blend(colorIndex(feature), colorIndex(feature) + 1, fraction),
                motion: .swirl,
                parameter: Geometry.hash(index * 7)
            )
        }
        return Formation(palette: palette, groups: [targets])
    }

    static func arrangement(features: [OnboardingFeature]) -> Formation {
        let perSymbol = Formation.particleCount / max(features.count, 1)
        let groups = features.enumerated().map { index, feature in
            Geometry.scaled(
                OnboardingParticlesSymbols.targets(for: feature, colorIndex: colorIndex(feature)),
                count: perSymbol,
                scale: 0.42,
                offset: arrangementOffset(index: index, count: features.count),
                radius: 2
            )
        }
        return Formation(palette: palette, groups: groups)
    }

    static func symbol(_ feature: OnboardingFeature) -> Formation {
        let targets = OnboardingParticlesSymbols.targets(for: feature, colorIndex: colorIndex(feature))
        return Formation(palette: palette, groups: [targets])
    }

    private static func arrangementOffset(index: Int, count: Int) -> CGPoint {
        guard count == 4 else {
            return CGPoint(x: (Double(index) - Double(count - 1) / 2) * 0.42, y: 0)
        }
        return CGPoint(x: index.isMultiple(of: 2) ? -0.25 : 0.25, y: index < 2 ? -0.22 : 0.22)
    }

    private static func colorIndex(_ feature: OnboardingFeature) -> Int {
        (OnboardingFeature.allCases.firstIndex(of: feature) ?? 0) * 2
    }
}
