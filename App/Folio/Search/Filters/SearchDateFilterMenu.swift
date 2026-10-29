import Planner
import SwiftUI

struct SearchDateFilterMenu: View {
    @Binding var dateFilter: SearchDateFilter?
    @State private var isPickingCustomRange = false

    var body: some View {
        SearchFilterChip(
            title: dateFilter?.title ?? String(localized: "Date.Any", table: "Search"),
            systemImage: "calendar.badge.clock",
            isActive: dateFilter != nil
        ) {
            Picker(String(localized: "Filter.Date", table: "Search"), selection: $dateFilter) {
                Text(String(localized: "Date.Any", table: "Search")).tag(SearchDateFilter?.none)
                ForEach(SearchDatePreset.allCases) { preset in
                    Text(preset.title).tag(Optional(SearchDateFilter.preset(preset)))
                }
            }
            .pickerStyle(.inline)
            Button(String(localized: "Date.Custom", table: "Search"), systemImage: "calendar") {
                isPickingCustomRange = true
            }
        }
        .accessibilityIdentifier("Search.Filter.Date")
        .sheet(isPresented: $isPickingCustomRange) {
            SearchDateRangeSheet(dateFilter: $dateFilter)
        }
    }
}
