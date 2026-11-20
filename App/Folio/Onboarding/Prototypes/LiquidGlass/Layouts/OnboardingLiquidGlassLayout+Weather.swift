import SwiftUI

extension OnboardingLiquidGlassLayout {
    private static let hours: [(symbol: String, tint: Color)] = [
        ("sun.max.fill", .yellow),
        ("cloud.sun.fill", .orange),
        ("cloud.fill", .cyan),
        ("cloud.rain.fill", .blue),
        ("moon.stars.fill", .indigo)
    ]

    var weatherPieces: [OnboardingLiquidGlassPiece] {
        let count = CGFloat(Self.hours.count)
        let spacing: CGFloat = 10
        let pillWidth = (size.width - 24 - spacing * (count - 1)) / count
        let bottom = size.height - 16
        let location = OnboardingLiquidGlassPiece(
            id: Self.hours.count,
            frame: CGRect(center: CGPoint(x: size.width / 2, y: 30), size: CGSize(width: 44, height: 44)),
            tint: .blue,
            content: .symbol("location.fill", [.cyan, .blue])
        )
        return Self.hours.enumerated().map { index, hour in
            let isRisen = index < phase
            let height: CGFloat = isRisen ? size.height * 0.62 : 64
            return OnboardingLiquidGlassPiece(
                id: index,
                frame: CGRect(
                    x: 12 + CGFloat(index) * (pillWidth + spacing),
                    y: bottom - height - (isRisen ? CGFloat(index % 2) * 10 : 0),
                    width: pillWidth,
                    height: height
                ),
                tint: isRisen ? hour.tint : .gray,
                content: .weather(hour.symbol)
            )
        } + [location]
    }
}
