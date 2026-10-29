import Planner
import SwiftUI

struct SearchResultsList: View {
    let groups: [SearchResultGroup]
    let filters: SearchFilters?
    let onOpen: (SearchDocument) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            List(groups) { group in
                Section {
                    ForEach(group.documents) { document in
                        Button {
                            onOpen(document)
                        } label: {
                            SearchResultRow(document: document, queryText: filters?.text ?? "")
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("Search.Result")
                    }
                } header: {
                    header(for: group)
                }
                .id(group.id)
            }
            .onChange(of: filters, initial: true) {
                scrollToUpcoming(in: groups, proxy: proxy)
            }
        }
    }

    @ViewBuilder
    private func header(for group: SearchResultGroup) -> some View {
        if let day = group.day {
            Text(day, format: .dateTime.weekday(.wide).month(.wide).day().year())
        } else {
            Text(String(localized: "Group.NoDate", table: "Search"))
        }
    }

    /// Results run from the past into the future, so open on today rather than two years ago.
    private func scrollToUpcoming(in groups: [SearchResultGroup], proxy: ScrollViewProxy) {
        let today = Calendar.current.startOfDay(for: .now)
        guard let upcoming = groups.first(where: { ($0.day ?? .distantFuture) >= today }) ?? groups.last else { return }
        proxy.scrollTo(upcoming.id, anchor: .top)
    }
}
