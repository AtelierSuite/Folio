import SwiftUI

extension OnboardingLiquidGlassLayout {
    var alertPieces: [OnboardingLiquidGlassPiece] {
        let banner = phase >= 1
            ? OnboardingLiquidGlassPiece(
                id: 0,
                frame: CGRect(x: 10, y: 8, width: size.width - 20, height: 66),
                cornerRadius: 24,
                tint: .orange,
                content: .banner
            )
            : OnboardingLiquidGlassPiece(
                id: 0,
                frame: CGRect(center: CGPoint(x: size.width / 2, y: 28), size: CGSize(width: 44, height: 44)),
                tint: .orange,
                content: .island
            )
        let event = OnboardingLiquidGlassPiece(
            id: 1,
            frame: timeline.frame(start: 2.4, duration: 1.0),
            cornerRadius: 12,
            tint: .orange,
            content: .event(.orange)
        )
        return [banner, event]
    }
}
