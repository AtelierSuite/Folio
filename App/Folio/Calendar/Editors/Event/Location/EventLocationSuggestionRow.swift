import Planner
import SwiftUI

struct EventLocationSuggestionRow: View {
    let suggestion: LocationSearchSuggestion
    let search: LocationSearch
    let action: () -> Void
    @State private var kind = LocationKind.place

    var body: some View {
        EventLocationChoiceRow(
            title: suggestion.title,
            subtitle: suggestion.subtitle,
            systemImage: kind.systemImage,
            color: kind.color,
            action: action
        )
        .task(id: suggestion) {
            // MapKit throttles searches, so only look up rows that stay on screen while typing pauses.
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled, let resolved = await search.kind(for: suggestion) else { return }
            withAnimation {
                kind = resolved
            }
        }
    }
}
