import AppIntents
import Planner
import SwiftUI

@main
struct FolioApp: App {
    @State private var calendarStore: CalendarStore
    @State private var permissionCenter: PermissionCenter
    @State private var notesLibrary: NotesLibrary
    @State private var noteNavigator: NoteNavigator
    @State private var destinationRequests: AppDestinationRequests
    @State private var workWeekPreferences = WorkWeekPreferences()
    @State private var notificationScheduler: NotificationScheduler
    @State private var arrivalAlerts: ArrivalAlertCenter
    @State private var notificationNavigator = NotificationNavigator()
    @State private var searchIndexer = SearchIndexer()
    @State private var weatherStore = WeatherStore.makeForApp()
    @State private var sleepStore: SleepStore
    @State private var systemTime = SystemTimeObserver()
    @State private var undoCoordinator: UndoCoordinator
    @State private var undoToastHosts = UndoToastHosts()
    @State private var countdowns: EventCountdownManager

    init() {
        let calendarStore = CalendarStore()
        _calendarStore = State(initialValue: calendarStore)
        let notificationScheduler = NotificationScheduler()
        let notificationNavigator = NotificationNavigator()
        _notificationScheduler = State(initialValue: notificationScheduler)
        _notificationNavigator = State(initialValue: notificationNavigator)
        _arrivalAlerts = State(initialValue: .makeForApp(following: notificationScheduler))
        NotificationPresentationDelegate.install(responseHandler: NotificationResponseHandler(
            reminders: calendarStore,
            routing: notificationNavigator,
            replan: { await notificationScheduler.replan() }
        ))
        _permissionCenter = State(initialValue: PermissionCenter(calendarStore: calendarStore, capabilities: .current))
        let notesLibrary = NotesLibrary(searchIndexer: NoteSpotlightIndexer())
        let noteNavigator = NoteNavigator()
        _notesLibrary = State(initialValue: notesLibrary)
        _noteNavigator = State(initialValue: noteNavigator)
        _undoCoordinator = State(initialValue: UndoCoordinator(
            store: calendarStore, library: notesLibrary, toastDuration: Self.undoToastDuration
        ))
        let countdowns = EventCountdownManager(source: calendarStore)
        _countdowns = State(initialValue: countdowns)
        AppDependencyManager.shared.add(dependency: countdowns)
        AppDependencyManager.shared.add(dependency: notesLibrary)
        AppDependencyManager.shared.add(dependency: noteNavigator)
        let sleepStore = SleepStore(capabilities: .current)
        sleepStore.startObservingChanges()
        _sleepStore = State(initialValue: sleepStore)
        let destinationRequests = AppDestinationRequests()
        _destinationRequests = State(initialValue: destinationRequests)
        AppDependencyManager.shared.add(dependency: destinationRequests)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .updatesSearchIndex()
                .environment(\.platformCapabilities, .current)
                .environment(calendarStore)
                .environment(notesLibrary)
                .environment(noteNavigator)
                .environment(destinationRequests)
                .environment(workWeekPreferences)
                .environment(permissionCenter)
                .refreshesPermissions(of: permissionCenter)
                .environment(notificationScheduler)
                .environment(arrivalAlerts)
                .environment(notificationNavigator)
                .environment(weatherStore)
                .environment(sleepStore)
                .notificationReplanTriggers(notificationScheduler)
                .opensNotesFromSpotlight(library: notesLibrary, navigator: noteNavigator)
                .opensNoteDeepLinks(library: notesLibrary, navigator: noteNavigator)
                .opensMeetingJoinDeepLinks()
                .environment(searchIndexer)
                .followsSystemTime(systemTime)
                .environment(undoCoordinator)
                .environment(undoToastHosts)
                .reloadsWidgets(on: calendarStore)
                .environment(countdowns)
                .reconcilesCountdowns(countdowns, with: calendarStore)
                .task {
                    calendarStore.startObservingChanges()
                    systemTime.startObserving {
                        await calendarStore.reloadAfterSystemTimeChange()
                        await notificationScheduler.replan()
                    }
                    await notesLibrary.start()
                    await seedSampleDataIfRequested()
                }
        }
        .notificationRefreshTask(notificationScheduler)
        .commands {
            TimelineZoomCommands()
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
            .environment(permissionCenter)
            .environment(notificationScheduler)
            .environment(arrivalAlerts)
            .environment(searchIndexer)
            .environment(weatherStore)
            .environment(sleepStore)
            .followsSystemTime(systemTime)
        }
        #endif
    }

    /// UI tests pass `-UndoToastSeconds` so slow queries don't outlast the toast.
    private static var undoToastDuration: Duration {
        #if DEBUG
        let seconds = UserDefaults.standard.double(forKey: "UndoToastSeconds")
        if seconds > 0 { return .seconds(seconds) }
        #endif
        return UndoCoordinator.toastDuration
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
        if arguments.contains(EventKitDataSource.arrivalTestLaunchArgument),
           let reference = try? EventKitDataSource.shared.seedArrivalTestEvent() {
            await arrivalAlerts.setEnabled(true, for: reference)
            if arguments.contains(ArrivalAlertCenter.simulateArrivalLaunchArgument) {
                await arrivalAlerts.simulateArrival(at: EventKitDataSource.arrivalTestCoordinate)
            }
        }
        if arguments.contains(EventKitDataSource.countdownSampleLaunchArgument) {
            try? EventKitDataSource.shared.seedCountdownSampleEvent()
        }
        if arguments.contains(EventKitDataSource.testMeetingAlertLaunchArgument) {
            try? EventKitDataSource.shared.seedTestMeetingAlert()
        }
        if arguments.contains(EventKitDataSource.testReminderAlertLaunchArgument) {
            try? await EventKitDataSource.shared.seedTestAlertReminder()
        }
        await SleepSampleDataSeeder.seedIfRequested(into: sleepStore, arguments: arguments)
        #endif
    }
}
