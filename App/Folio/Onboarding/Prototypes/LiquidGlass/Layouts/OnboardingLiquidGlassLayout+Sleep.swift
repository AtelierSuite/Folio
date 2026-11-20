import SwiftUI

extension OnboardingLiquidGlassLayout {
    private static let barHeight: CGFloat = 56

    var sleepPieces: [OnboardingLiquidGlassPiece] {
        let isGrown = phase >= 1
        let barCenterY = size.height * 0.36
        let sunCenterX = size.width - 12 - Self.barHeight / 2
        let barWidth = isGrown ? sunCenterX - 12 : Self.barHeight
        let bar = OnboardingLiquidGlassPiece(
            id: 0,
            frame: CGRect(x: 12, y: barCenterY - Self.barHeight / 2, width: barWidth, height: Self.barHeight),
            tint: .indigo,
            content: .sleep(isGrown: isGrown)
        )
        let sun = OnboardingLiquidGlassPiece(
            id: 1,
            frame: CGRect(
                center: CGPoint(x: sunCenterX, y: barCenterY),
                size: CGSize(width: Self.barHeight, height: Self.barHeight)
            ),
            tint: .orange,
            content: .symbol("sun.horizon.fill", [.yellow, .orange])
        )
        let plan = OnboardingLiquidGlassPiece(
            id: 2,
            frame: CGRect(
                x: size.width * 0.5,
                y: barCenterY + Self.barHeight / 2 + (isGrown ? 24 : 40),
                width: size.width * 0.5 - 12,
                height: 48
            ),
            cornerRadius: 14,
            tint: .blue,
            content: .event(.blue)
        )
        return [bar, sun, plan]
    }
}
