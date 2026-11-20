import SwiftUI

struct OnboardingParticlesField: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var engine = OnboardingParticlesEngine()
    let scene: OnboardingParticlesScene

    var body: some View {
        Group {
            if reducesMotion {
                Canvas { context, size in
                    engine.drawStill(scene, in: &context, size: size)
                }
            } else {
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        engine.draw(scene, in: &context, size: size, date: timeline.date)
                    }
                }
            }
        }
        .background {
            RadialGradient(colors: [scene.tint.opacity(0.16), .clear], center: .center, startRadius: 0, endRadius: 220)
                .animation(.easeInOut(duration: 1.2), value: scene.identifier)
        }
        .mask {
            LinearGradient(
                stops: [.init(color: .black, location: 0.84), .init(color: .clear, location: 1)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .accessibilityHidden(true)
    }
}
