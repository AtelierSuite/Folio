import Planner
import SwiftUI

struct RootView: View {
    @Environment(NoteNavigator.self) private var noteNavigator
    @SceneStorage("RootView.selectedTab") private var selectedTab: AppTab = .calendar
    @State private var router = AppRouter()

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(String(localized: "Tab.Calendar", table: "Root"), systemImage: "calendar", value: AppTab.calendar) {
                CalendarView()
            }
            Tab(String(localized: "Tab.Lists", table: "Root"), systemImage: "checklist", value: AppTab.lists) {
                ListsView()
            }
            Tab(String(localized: "Tab.Notes", table: "Root"), systemImage: "note.text", value: AppTab.notes) {
                NotesView()
            }
            #if os(iOS)
            Tab(String(localized: "Tab.Settings", table: "Root"), systemImage: "gearshape", value: AppTab.settings) {
                NavigationStack {
                    SettingsView()
                }
            }
            #endif
            Tab(
                String(localized: "Tab.Search", table: "Root"),
                systemImage: "magnifyingglass",
                value: AppTab.search,
                role: searchTabRole
            ) {
                SearchView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .undoToastHost()
        .connectsUndo()
        .onboarding()
        .handlesNotificationRoutes()
        .environment(router)
        .opensCalendarDeepLinks(with: router)
        .onChange(of: router.pendingDestination) { _, destination in
            if let destination {
                selectedTab = destination.tab
            }
        }
        .onChange(of: noteNavigator.requestedNoteURL, initial: true) { _, url in
            if let url {
                noteNavigator.requestedNoteURL = nil
                router.open(.note(url))
            }
        }
    }

    private var searchTabRole: TabRole {
        #if os(iOS)
        if #available(iOS 27.0, *) {
            return .prominent
        }
        #endif
        return .search
    }
}
