import Planner
import SwiftUI

extension View {
    func invitationCardStyle(
        _ style: InvitationCardStyle,
        color: Color,
        in shape: some InsettableShape
    ) -> some View {
        modifier(InvitationCardStyleModifier(style: style, color: color, shape: shape))
    }
}

private struct InvitationCardStyleModifier<CardShape: InsettableShape>: ViewModifier {
    let style: InvitationCardStyle
    let color: Color
    let shape: CardShape

    @ViewBuilder
    func body(content: Content) -> some View {
        let styled = content
            .overlay {
                if style == .outlined {
                    shape.strokeBorder(color, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                }
            }
            .opacity(style == .dimmed ? 0.45 : 1)
        if let statusLabel = style.accessibilityLabel {
            styled.accessibilityLabel { label in
                Text(statusLabel)
                label
            }
        } else {
            styled
        }
    }
}

extension InvitationCardStyle {
    var accessibilityLabel: String? {
        switch self {
        case .standard: nil
        case .outlined: String(localized: "Card.Pending", table: "Invitations")
        case .dimmed: String(localized: "Card.Declined", table: "Invitations")
        }
    }
}
