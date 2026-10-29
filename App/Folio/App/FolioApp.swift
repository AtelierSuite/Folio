import Planner
import SwiftUI

@main
struct FolioApp: App {
    @State private var calendarStore = CalendarStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.platformCapabilities, .current)
                .environment(calendarStore)
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
