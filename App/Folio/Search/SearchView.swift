import Planner
import SwiftUI

struct SearchView: View {
    @Environment(SearchIndexer.self) private var indexer
    @Environment(CalendarStore.self) private var store
    @Environment(NotesLibrary.self) private var library
    @Environment(AppRouter.self) private var router
    @State private var filters = SearchFilters()
    @State private var groups: [SearchResultGroup] = []
    @State private var searchedFilters: SearchFilters?

    var body: some View {
        NavigationStack {
            SearchContent(
                filters: filters,
                searchedFilters: searchedFilters,
                groups: groups,
                isIndexing: indexer.isIndexing,
                onOpen: { router.open($0.destination) }
            )
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 0) {
                    SearchFilterBar(filters: $filters)
                    SearchPermissionBanner()
                }
                .background(.bar)
            }
            .navigationTitle(String(localized: "Title", table: "Search"))
            .searchable(
                text: $filters.text,
                placement: Self.searchFieldPlacement,
                prompt: String(localized: "Prompt", table: "Search")
            )
        }
        .task {
            await library.start()
            await indexer.activate()
            await indexer.updateNotes(library.notes)
        }
        .task(id: request) {
            await search()
        }
    }

    /// The filter bar inset otherwise makes the navigation bar hide the search field until the list scrolls.
    private static var searchFieldPlacement: SearchFieldPlacement {
        #if os(iOS)
        .navigationBarDrawer(displayMode: .always)
        #else
        .automatic
        #endif
    }

    private var request: SearchRequest {
        SearchRequest(filters: filters, hidden: store.hiddenCalendarIdentifiers, revision: indexer.revision)
    }

    private func search() async {
        if searchedFilters?.text != filters.text {
            try? await Task.sleep(for: .milliseconds(150))
            guard !Task.isCancelled else { return }
        }
        let documents = await indexer.search(filters.query(hiding: store.hiddenCalendarIdentifiers))
        guard !Task.isCancelled else { return }
        groups = SearchResultGroup.grouped(documents)
        searchedFilters = filters
    }
}

private struct SearchRequest: Hashable {
    let filters: SearchFilters
    let hidden: Set<String>
    let revision: Int
}
