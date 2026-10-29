import AppIntents
import Planner
import SwiftUI

@main
struct FolioApp: App {
    @State private var calendarStore: CalendarStore
    @State private var permissionCenter: PermissionCenter
    @State private var notesLibrary: NotesLibrary
    @State private var noteNavigator: NoteNavigator
    @State private var workWeekPreferences = WorkWeekPreferences()
    @State private var notificationScheduler = NotificationScheduler()
    @State private var searchIndexer = SearchIndexer()

    init() {
        NotificationPresentationDelegate.install()
        let calendarStore = CalendarStore()
        _calendarStore = State(initialValue: calendarStore)
        _permissionCenter = State(initialValue: PermissionCenter(calendarStore: calendarStore, capabilities: .current))
        let notesLibrary = NotesLibrary(searchIndexer: NoteSpotlightIndexer())
        let noteNavigator = NoteNavigator()
        _notesLibrary = State(initialValue: notesLibrary)
        _noteNavigator = State(initialValue: noteNavigator)
        AppDependencyManager.shared.add(dependency: notesLibrary)
        AppDependencyManager.shared.add(dependency: noteNavigator)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .updatesSearchIndex()
                .environment(\.platformCapabilities, .current)
                .environment(calendarStore)
                .environment(notesLibrary)
                .environment(noteNavigator)
                .environment(workWeekPreferences)
                .environment(permissionCenter)
                .refreshesPermissions(of: permissionCenter)
                .environment(notificationScheduler)
                .notificationReplanTriggers(notificationScheduler)
                .opensNotesFromSpotlight(library: notesLibrary, navigator: noteNavigator)
                .environment(searchIndexer)
                .task {
                    calendarStore.startObservingChanges()
                    await notesLibrary.start()
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
            .environment(searchIndexer)
        }
        #endif
    }

    private func seedSampleDataIfRequested() async {
        #if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains(EventKitDataSource.sampleDataLaunchArgument) {
            try? await EventKitDataSource.shared.seedSampleData()
        }
        if arguments.contains(EventKitDataSource.testAlertLaunchArgument) {
            try? EventKitDataSource.shared.seedTestAlertEvent()
        }
        #endif
    }
}
