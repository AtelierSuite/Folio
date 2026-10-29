import SwiftUI

struct CalendarView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                String(localized: "Placeholder.Title", table: "Calendar"),
                systemImage: "calendar",
                description: Text(String(localized: "Placeholder.Description", table: "Calendar"))
            )
            .navigationTitle(String(localized: "Title", table: "Calendar"))
        }
    }
}
