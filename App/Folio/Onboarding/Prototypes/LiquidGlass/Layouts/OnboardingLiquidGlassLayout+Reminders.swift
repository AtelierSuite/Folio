import SwiftUI

extension OnboardingLiquidGlassLayout {
    private static let reminderColors: [Color] = [.orange, .teal, .pink]
    private static let rowHeight: CGFloat = 52
    private static let rowSpacing: CGFloat = 14

    var reminderPieces: [OnboardingLiquidGlassPiece] {
        let count = Self.reminderColors.count
        let totalHeight = CGFloat(count) * Self.rowHeight + CGFloat(count - 1) * Self.rowSpacing
        let top = (size.height - totalHeight) / 2
        return Self.reminderColors.enumerated().map { index, color in
            let isDone = index < phase
            return OnboardingLiquidGlassPiece(
                id: index,
                frame: CGRect(
                    x: isDone ? 24 : 12,
                    y: top + CGFloat(index) * (Self.rowHeight + Self.rowSpacing),
                    width: size.width - 36,
                    height: Self.rowHeight
                ),
                tint: isDone ? .green : color,
                content: .reminder(color, isDone: isDone)
            )
        }
    }
}
