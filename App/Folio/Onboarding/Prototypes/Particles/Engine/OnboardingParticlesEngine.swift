import SwiftUI

final class OnboardingParticlesEngine {
    private struct Particle {
        var position: CGPoint
        var radius: CGFloat
        var opacity: Double
        var stretch: CGFloat
        var red: Double
        var green: Double
        var blue: Double
    }

    private static let transitionDuration = 1.15
    private static let maximumDelay = 0.4
    private static let paletteCapacity = 8

    private var particles: [Particle]
    private let delays: [Double]
    private let arcs: [Double]
    private var resolvedPalette: [Color.Resolved]
    private var neutral = Color.Resolved(red: 0.5, green: 0.5, blue: 0.5)
    private var formation: OnboardingParticlesFormation?
    private var sceneIdentifier: String?
    private var sceneStart = 0.0
    private var phaseIndex = 0
    private var transitionStart = 0.0
    private let epoch = Date.timeIntervalSinceReferenceDate

    init() {
        let count = OnboardingParticlesFormation.particleCount
        particles = (0..<count).map { index in
            let angle = OnboardingParticlesGeometry.hash(index * 23) * 2 * .pi
            let distance = OnboardingParticlesGeometry.hash(index * 29) * 0.05
            return Particle(
                position: CGPoint(x: cos(angle) * distance, y: sin(angle) * distance),
                radius: 1, opacity: 0, stretch: 1, red: 0.5, green: 0.5, blue: 0.5
            )
        }
        delays = (0..<count).map { OnboardingParticlesGeometry.hash($0 * 31 + 7) * Self.maximumDelay }
        arcs = (0..<count).map { (OnboardingParticlesGeometry.hash($0 * 37 + 1) - 0.5) * 0.7 }
        resolvedPalette = Array(repeating: neutral, count: Self.paletteCapacity)
    }

    func draw(_ scene: OnboardingParticlesScene, in context: inout GraphicsContext, size: CGSize, date: Date) {
        let time = date.timeIntervalSinceReferenceDate - epoch
        if scene.identifier != sceneIdentifier {
            sceneIdentifier = scene.identifier
            sceneStart = time
            phaseIndex = -1
        }
        let newPhase = scene.phaseIndex(at: time - sceneStart)
        if newPhase != phaseIndex {
            capture(at: time)
            phaseIndex = newPhase
            formation = scene.phases[newPhase].formation
            transitionStart = time
        }
        guard let formation else { return }
        resolve(formation.palette, in: context.environment)
        for index in particles.indices {
            render(current(index, in: formation, at: time), in: &context, size: size)
        }
    }

    func drawStill(_ scene: OnboardingParticlesScene, in context: inout GraphicsContext, size: CGSize) {
        let formation = scene.phases[scene.stillPhase].formation
        resolve(formation.palette, in: context.environment)
        for target in formation.targets {
            let frame = target.frame(at: 2.4)
            let color = color(for: target.ink)
            render(
                Particle(
                    position: frame.position, radius: frame.radius, opacity: frame.opacity, stretch: frame.stretch,
                    red: Double(color.red), green: Double(color.green), blue: Double(color.blue)
                ),
                in: &context,
                size: size
            )
        }
    }

    private func capture(at time: Double) {
        guard let formation else { return }
        for index in particles.indices {
            particles[index] = current(index, in: formation, at: time)
        }
    }

    private func current(_ index: Int, in formation: OnboardingParticlesFormation, at time: Double) -> Particle {
        let origin = particles[index]
        let target = formation.targets[index]
        let frame = target.frame(at: time)
        let color = color(for: target.ink)
        let progress = min(max((time - transitionStart - delays[index]) / Self.transitionDuration, 0), 1)
        let eased = progress < 0.5 ? 4 * progress * progress * progress : 1 - pow(-2 * progress + 2, 3) / 2
        let deltaX = frame.position.x - origin.position.x
        let deltaY = frame.position.y - origin.position.y
        let bend = sin(progress * .pi) * arcs[index]
        return Particle(
            position: CGPoint(
                x: origin.position.x + deltaX * eased - deltaY * bend,
                y: origin.position.y + deltaY * eased + deltaX * bend
            ),
            radius: origin.radius + (frame.radius - origin.radius) * eased,
            opacity: origin.opacity + (frame.opacity - origin.opacity) * eased,
            stretch: origin.stretch + (frame.stretch - origin.stretch) * eased,
            red: origin.red + (Double(color.red) - origin.red) * eased,
            green: origin.green + (Double(color.green) - origin.green) * eased,
            blue: origin.blue + (Double(color.blue) - origin.blue) * eased
        )
    }

    private func render(_ particle: Particle, in context: inout GraphicsContext, size: CGSize) {
        guard particle.opacity > 0.01 else { return }
        let scale = size.height
        let width = particle.radius * 2
        let height = width * particle.stretch
        let rect = CGRect(
            x: size.width / 2 + particle.position.x * scale - width / 2,
            y: size.height / 2 + particle.position.y * scale - height / 2,
            width: width,
            height: height
        )
        context.fill(
            Path(ellipseIn: rect),
            with: .color(
                .sRGB, red: particle.red, green: particle.green, blue: particle.blue, opacity: particle.opacity
            )
        )
    }

    private func resolve(_ palette: [Color], in environment: EnvironmentValues) {
        neutral = Color.primary.resolve(in: environment)
        for index in palette.indices.prefix(Self.paletteCapacity) {
            resolvedPalette[index] = palette[index].resolve(in: environment)
        }
    }

    private func color(for ink: OnboardingParticlesInk) -> Color.Resolved {
        switch ink {
        case .neutral:
            return neutral
        case .color(let index):
            return resolvedPalette[index]
        case .blend(let first, let second, let fraction):
            let start = resolvedPalette[first]
            let end = resolvedPalette[second]
            let amount = Float(min(max(fraction, 0), 1))
            return Color.Resolved(
                red: start.red + (end.red - start.red) * amount,
                green: start.green + (end.green - start.green) * amount,
                blue: start.blue + (end.blue - start.blue) * amount
            )
        }
    }
}
