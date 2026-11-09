import Planner
import SwiftUI

struct NoteSortMenu: View {
    @Binding var sortOrder: NoteSortOrder

    var body: some View {
        Menu(String(localized: "Sort.Title", table: "Notes"), systemImage: "arrow.up.arrow.down") {
            Picker(String(localized: "Sort.Title", table: "Notes"), selection: $sortOrder) {
                ForEach(NoteSortOrder.allCases) { order in
                    Text(order.title)
                        .tag(order)
                }
            }
            .pickerStyle(.inline)
        }
    }
}
