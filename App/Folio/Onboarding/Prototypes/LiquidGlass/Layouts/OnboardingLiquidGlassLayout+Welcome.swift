import SwiftUI

extension OnboardingLiquidGlassLayout {
    private static let bubbleSize: CGFloat = 76

    var welcomePieces: [OnboardingLiquidGlassPiece] {
        features.enumerated().map { index, feature in
            OnboardingLiquidGlassPiece(
                id: index,
                frame: CGRect(
                    center: bubbleCenter(index: index, count: features.count),
                    size: CGSize(width: Self.bubbleSize, height: Self.bubbleSize)
                ),
                tint: feature.gradientColors[0],
                content: .symbol(feature.systemImage, feature.gradientColors)
            )
        }
    }

    private func bubbleCenter(index: Int, count: Int) -> CGPoint {
        let middle = CGPoint(x: size.width / 2, y: size.height / 2)
        let centredIndex = CGFloat(index) - CGFloat(count - 1) / 2
        switch phase {
        case 1:
            return CGPoint(x: middle.x + centredIndex * 34, y: middle.y + (index.isMultiple(of: 2) ? -6 : 6))
        case 2:
            let angle = Double(index) / Double(max(count, 1)) * 2 * .pi - .pi / 2
            return CGPoint(x: middle.x + cos(angle) * 72, y: middle.y + sin(angle) * 72)
        default:
            let spacing = min(size.width / CGFloat(max(count, 1)), Self.bubbleSize + 22)
            return CGPoint(x: middle.x + centredIndex * spacing, y: middle.y + (index.isMultiple(of: 2) ? -22 : 22))
        }
    }
}
