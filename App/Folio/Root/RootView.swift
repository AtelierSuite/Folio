import SwiftUI

struct RootView: View {
    @SceneStorage("RootView.selectedTab") private var selectedTab: AppTab = .calendar

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(String(localized: "Tab.Calendar", table: "Root"), systemImage: "calendar", value: AppTab.calendar) {
                CalendarView()
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
            Tab(value: AppTab.search, role: .search) {
                SearchView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .onboarding()
    }
}
