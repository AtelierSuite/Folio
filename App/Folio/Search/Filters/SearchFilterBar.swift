import Planner
import SwiftUI

struct SearchFilterBar: View {
    @Binding var filters: SearchFilters

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                SearchKindFilterMenu(filters: $filters)
                if filters.kind != .note {
                    SearchCalendarFilterMenu(filters: $filters)
                }
                SearchDateFilterMenu(dateFilter: $filters.dateFilter)
                Toggle(isOn: $filters.requiresMeetingLink) {
                    Label(String(localized: "Filter.MeetingLink", table: "Search"), systemImage: "video")
                        .font(.subheadline)
                }
                .toggleStyle(.button)
                .buttonStyle(.bordered)
                .tint(filters.requiresMeetingLink ? .accentColor : .secondary)
                .fixedSize()
                .accessibilityIdentifier("Search.Filter.MeetingLink")
                if filters.isFiltering {
                    Button(String(localized: "Filter.Clear", table: "Search")) {
                        filters.clear()
                    }
                    .font(.subheadline)
                    .buttonStyle(.borderless)
                    .fixedSize()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
        .scrollIndicators(.hidden)
    }
}
