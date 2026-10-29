import Planner
import SwiftUI

@main
struct FolioApp: App {
    @State private var calendarStore = CalendarStore()
    @State private var notesLibrary = NotesLibrary()
    @State private var workWeekPreferences = WorkWeekPreferences()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.platformCapabilities, .current)
                .environment(calendarStore)
                .environment(notesLibrary)
                .environment(workWeekPreferences)
                .task {
                    calendarStore.startObservingChanges()
                    await seedSampleDataIfRequested()
                }
        }
        #if os(macOS)
        Settings {
            NavigationStack {
                SettingsView()
            }
            .environment(\.platformCapabilities, .current)
            .environment(calendarStore)
            .environment(notesLibrary)
            .environment(workWeekPreferences)
        }
        #endif
    }

    private func seedSampleDataIfRequested() async {
        #if DEBUG
        guard ProcessInfo.processInfo.arguments.contains(EventKitDataSource.sampleDataLaunchArgument) else { return }
        try? await EventKitDataSource.shared.seedSampleData()
        #endif
    }
}
