import Planner
import SwiftUI

struct SearchKindFilterMenu: View {
    @Binding var filters: SearchFilters

    var body: some View {
        SearchFilterChip(
            title: filters.kind?.title ?? String(localized: "Kind.All", table: "Search"),
            systemImage: filters.kind?.systemImage ?? "square.stack",
            isActive: filters.kind != nil
        ) {
            Picker(String(localized: "Filter.Kind", table: "Search"), selection: $filters.kind) {
                Text(String(localized: "Kind.All", table: "Search")).tag(SearchItemKind?.none)
                ForEach(SearchItemKind.allCases, id: \.self) { kind in
                    Label(kind.title, systemImage: kind.systemImage).tag(Optional(kind))
                }
            }
            .pickerStyle(.inline)
        }
        .accessibilityIdentifier("Search.Filter.Kind")
        .onChange(of: filters.kind) { _, kind in
            if kind == .note {
                filters.containerIdentifier = nil
            }
        }
    }
}
