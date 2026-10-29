import SwiftUI

struct SearchView: View {
    @State private var query = ""

    var body: some View {
        NavigationStack {
            ContentUnavailableView.search(text: query)
                .navigationTitle(String(localized: "Title", table: "Search"))
        }
        .searchable(text: $query)
    }
}
