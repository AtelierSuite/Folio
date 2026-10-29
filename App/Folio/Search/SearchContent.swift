import Planner
import SwiftUI

struct SearchContent: View {
    let filters: SearchFilters
    let groups: [SearchResultGroup]
    let isSearching: Bool
    let onOpen: (SearchDocument) -> Void

    private var hasQuery: Bool {
        !filters.text.trimmingCharacters(in: .whitespaces).isEmpty || filters.isFiltering
    }

    var body: some View {
        if !hasQuery {
            ContentUnavailableView(
                String(localized: "Empty.Title", table: "Search"),
                systemImage: "magnifyingglass",
                description: Text(String(localized: "Empty.Description", table: "Search"))
            )
        } else if groups.isEmpty {
            if isSearching {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ContentUnavailableView.search(text: filters.text)
            }
        } else {
            SearchResultsList(groups: groups, queryText: filters.text, onOpen: onOpen)
        }
    }
}
