import SwiftUI

struct OnboardingLiquidGlassPieceView: View {
    let piece: OnboardingLiquidGlassPiece

    var body: some View {
        ZStack {
            OnboardingLiquidGlassPieceContentView(content: piece.content)
                .id(piece.content.kind)
                .transition(.opacity.combined(with: .scale(scale: 0.85)))
        }
        .frame(width: piece.frame.width, height: piece.frame.height)
        .clipShape(.rect(cornerRadius: piece.cornerRadius))
        .glassEffect(.regular.tint(piece.tint.opacity(0.3)), in: .rect(cornerRadius: piece.cornerRadius))
    }
}
