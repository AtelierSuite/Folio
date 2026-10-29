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
    @State private var weatherStore = WeatherStore.makeForApp()
    @State private var sleepStore: SleepStore

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
        let sleepStore = SleepStore(capabilities: .current)
        sleepStore.startObservingChanges()
        _sleepStore = State(initialValue: sleepStore)
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
                .environment(weatherStore)
                .environment(sleepStore)
                .notificationReplanTriggers(notificationScheduler)
                .opensNotesFromSpotlight(library: notesLibrary, navigator: noteNavigator)
                .opensNoteDeepLinks(library: notesLibrary, navigator: noteNavigator)
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
            .environment(weatherStore)
            .environment(sleepStore)
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
        await SleepSampleDataSeeder.seedIfRequested(into: sleepStore, arguments: arguments)
        #endif
    }
}
