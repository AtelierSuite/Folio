import SwiftUI

struct OnboardingLiquidGlassStage: View {
    @Namespace private var glassNamespace
    let step: OnboardingStep
    let phase: Int
    let features: [OnboardingFeature]

    var body: some View {
        GeometryReader { proxy in
            let layout = OnboardingLiquidGlassLayout(size: proxy.size, phase: phase, features: features)
            ZStack(alignment: .topLeading) {
                OnboardingLiquidGlassHourGrid(
                    timeline: layout.timeline,
                    showsNow: step == .setup(.alerts)
                )
                .opacity(layout.showsHourGrid(for: step) ? 1 : 0)
                GlassEffectContainer(spacing: 16) {
                    ZStack(alignment: .topLeading) {
                        ForEach(layout.pieces(for: step)) { piece in
                            OnboardingLiquidGlassPieceView(piece: piece)
                                .glassEffectID(piece.id, in: glassNamespace)
                                .position(x: piece.frame.midX, y: piece.frame.midY)
                        }
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
                }
            }
        }
        .frame(height: Metrics.height)
    }

    private enum Metrics {
        #if os(macOS)
        static let height: CGFloat = 200
        #else
        static let height: CGFloat = 260
        #endif
    }
}
