import SwiftUI

struct CalendarView: View {
    var body: some View {
        NavigationStack {
            AgendaView()
                .navigationTitle(String(localized: "Title", table: "Calendar"))
        }
    }
}
