import Planner
import SwiftUI

extension View {
    @ViewBuilder
    func timelineEntrySelection(_ entry: TimelineEntry, onSelect: ((TimelineEntry) -> Void)?) -> some View {
        if let onSelect {
            Button {
                onSelect(entry)
            } label: {
                self
            }
            .buttonStyle(.plain)
        } else {
            self
        }
    }
}
