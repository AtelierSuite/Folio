import Planner
import SwiftUI

@main
struct FolioApp: App {
    @State private var calendarStore: CalendarStore
    @State private var permissionCenter: PermissionCenter
    @State private var notesLibrary = NotesLibrary()
    @State private var workWeekPreferences = WorkWeekPreferences()
    @State private var notificationScheduler = NotificationScheduler()

    init() {
        NotificationPresentationDelegate.install()
        let calendarStore = CalendarStore()
        _calendarStore = State(initialValue: calendarStore)
        _permissionCenter = State(initialValue: PermissionCenter(calendarStore: calendarStore, capabilities: .current))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.platformCapabilities, .current)
                .environment(calendarStore)
                .environment(notesLibrary)
                .environment(workWeekPreferences)
                .environment(permissionCenter)
                .refreshesPermissions(of: permissionCenter)
                .environment(notificationScheduler)
                .notificationReplanTriggers(notificationScheduler)
                .task {
                    calendarStore.startObservingChanges()
                    await seedSampleDataIfRequested()
                }
        }
        .notificationRefreshTask(notificationScheduler)
        #if os(macOS)
        Settings {
            NavigationStack {
                SettingsView()
            }
            .environment(\.platformCapabilities, .current)
            .environment(calendarStore)
            .environment(notesLibrary)
            .environment(workWeekPreferences)
            .environment(permissionCenter)
            .environment(notificationScheduler)
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
