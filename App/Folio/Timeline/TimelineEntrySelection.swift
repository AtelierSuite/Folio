import Planner
import SwiftUI

extension View {
    /// Events get the quick actions from the screen's `eventActionsHost`; anything else calls `onSelect`.
    func timelineEntrySelection(_ entry: TimelineEntry, onSelect: ((TimelineEntry) -> Void)?) -> some View {
        modifier(TimelineEntrySelectionModifier(entry: entry, onSelect: onSelect))
    }
}

private struct TimelineEntrySelectionModifier: ViewModifier {
    @Environment(\.eventActions) private var actions
    let entry: TimelineEntry
    let onSelect: ((TimelineEntry) -> Void)?

    func body(content: Content) -> some View {
        if let actions, let event = actions.event(for: entry) {
            content.eventInteractions(event, actions: actions)
        } else if let onSelect {
            content
                .contentShape(Rectangle())
                .onTapGesture { onSelect(entry) }
                .accessibilityAddTraits(.isButton)
                .accessibilityAction { onSelect(entry) }
        } else {
            content
        }
    }
}
