import Planner
import SwiftUI

extension View {
    /// Keeps the search index in step with calendar and note changes once search has been used.
    func updatesSearchIndex() -> some View {
        modifier(SearchIndexUpdates())
    }
}

private struct SearchIndexUpdates: ViewModifier {
    @Environment(SearchIndexer.self) private var indexer
    @Environment(CalendarStore.self) private var store
    @Environment(NotesLibrary.self) private var library

    func body(content: Content) -> some View {
        content
            .task(id: store.contentRevision) {
                await indexer.reindexCalendar()
            }
            .onChange(of: library.notes) { _, notes in
                Task {
                    await indexer.updateNotes(notes)
                }
            }
    }
}
