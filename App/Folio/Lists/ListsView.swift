import Planner
import SwiftUI

struct ListsView: View {
    @Environment(CalendarStore.self) private var store
    @SceneStorage("ListsView.selectedListIdentifier") private var selectedListIdentifier: String?

    var body: some View {
        SidebarSplitView {
            ReminderListsSidebar(selection: $selectedListIdentifier)
        } detail: {
            detail
        }
    }

    @ViewBuilder
    private var detail: some View {
        if let list = store.reminderLists.first(where: { $0.id == selectedListIdentifier }) {
            ReminderListDetailView(list: list)
                .id(list.id)
        } else {
            ContentUnavailableView(
                String(localized: "NoSelection.Title", table: "Lists"),
                systemImage: "checklist"
            )
        }
    }
}
