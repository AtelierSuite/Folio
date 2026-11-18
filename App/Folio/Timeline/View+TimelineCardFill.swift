import Planner
import SwiftUI

extension View {
    func timelineCardFill(for entry: TimelineEntry, in shape: some InsettableShape) -> some View {
        modifier(TimelineCardFillModifier(entry: entry, shape: shape))
    }
}

private struct TimelineCardFillModifier<CardShape: InsettableShape>: ViewModifier {
    let entry: TimelineEntry
    let shape: CardShape

    func body(content: Content) -> some View {
        if entry.isBirthday {
            content
                .foregroundStyle(BirthdayStyle.text)
                .background(BirthdayStyle.fill, in: shape)
        } else {
            content
                .foregroundStyle(Color(entry.color))
                .background(Color(entry.color).opacity(0.3), in: shape)
                .invitationCardStyle(entry.invitationStyle, color: Color(entry.color), in: shape)
        }
    }
}
