import Planner
import SwiftUI

extension View {
    /// A tap gesture rather than a `Button`: a button claims the touch for itself, which keeps
    /// the timeline's long press to drag from ever starting on a card.
    @ViewBuilder
    func timelineEntrySelection(_ entry: TimelineEntry, onSelect: ((TimelineEntry) -> Void)?) -> some View {
        if let onSelect {
            contentShape(Rectangle())
                .onTapGesture { onSelect(entry) }
                .accessibilityAddTraits(.isButton)
                .accessibilityAction { onSelect(entry) }
        } else {
            self
        }
    }
}
