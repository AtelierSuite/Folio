import AppIntents
import Planner
import SwiftUI

@main
struct FolioApp: App {
    @State private var calendarStore: CalendarStore
    @State private var permissionCenter: PermissionCenter
    @State private var notesLibrary: NotesLibrary
    @State private var noteNavigator: NoteNavigator
    @State private var noteLinkMaintenance: NoteLinkMaintenance
    @State private var destinationRequests: AppDestinationRequests
    @State private var workWeekPreferences = WorkWeekPreferences()
    @State private var notificationScheduler: NotificationScheduler
    @State private var arrivalAlerts: ArrivalAlertCenter
    @State private var leaveAlerts: LeaveAlertCenter
    @State private var wakeUpAlarms: WakeUpAlarmCenter
    @State private var standaloneAlarms: StandaloneAlarmCenter
    @State private var notificationNavigator = NotificationNavigator()
    @State private var searchIndexer = SearchIndexer()
    @State private var weatherStore = WeatherStore.makeForApp()
    @State private var travelTimeStore = TravelTimeStore()
    @State private var sleepStore: SleepStore
    @State private var flexTime: FlexTimeCenter
    @State private var medicationStore: MedicationStore
    @State private var systemTime = SystemTimeObserver()
    @State private var undoCoordinator: UndoCoordinator
    @State private var undoToastHosts = UndoToastHosts()
    @State private var countdowns: EventCountdownManager
    #if os(macOS)
    @State private var menuBarAgenda = MenuBarAgenda()
    #endif

    static let mainWindowIdentifier = "main"

    init() {
        #if DEBUG
        ScreenshotStage.prepareSettings()
        #endif
        let calendarStore = CalendarStore()
        _calendarStore = State(initialValue: calendarStore)
        let notificationScheduler = NotificationScheduler()
        let notificationNavigator = NotificationNavigator()
        _notificationScheduler = State(initialValue: notificationScheduler)
        _notificationNavigator = State(initialValue: notificationNavigator)
        let arrivalAlerts = ArrivalAlertCenter.makeForApp()
        let leaveAlerts = LeaveAlertCenter(capabilities: .current)
        let wakeUpAlarms = WakeUpAlarmCenter.makeForApp()
        let standaloneAlarms = StandaloneAlarmCenter(capabilities: .current)
        let medicationStore = MedicationStore.makeForApp(notificationScheduler: notificationScheduler)
        _medicationStore = State(initialValue: medicationStore)
        notificationScheduler.replansDependentAlerts(
            arrivalAlerts, leaveAlerts, wakeUpAlarms, standaloneAlarms, medicationStore
        )
        _arrivalAlerts = State(initialValue: arrivalAlerts)
        _leaveAlerts = State(initialValue: leaveAlerts)
        _wakeUpAlarms = State(initialValue: wakeUpAlarms)
        _standaloneAlarms = State(initialValue: standaloneAlarms)
        NotificationPresentationDelegate.install(responseHandler: NotificationResponseHandler(
            reminders: calendarStore,
            routing: notificationNavigator,
            replan: { await notificationScheduler.replan() }
        ))
        _permissionCenter = State(initialValue: PermissionCenter(calendarStore: calendarStore, capabilities: .current))
        let notesLibrary = NotesLibrary(searchIndexer: NoteSpotlightIndexer(), index: .persistent())
        notificationScheduler.attachesLinkedNoteImages(from: notesLibrary)
        _noteLinkMaintenance = State(
            initialValue: NoteLinkMaintenance(library: notesLibrary, calendarStore: calendarStore)
        )
        let noteNavigator = NoteNavigator()
        _notesLibrary = State(initialValue: notesLibrary)
        _noteNavigator = State(initialValue: noteNavigator)
        _undoCoordinator = State(initialValue: UndoCoordinator(
            store: calendarStore, library: notesLibrary, toastDuration: Self.undoToastDuration
        ))
        let countdowns = EventCountdownManager(source: calendarStore)
        _countdowns = State(initialValue: countdowns)
        let sleepStore = SleepStore.makeForApp()
        _sleepStore = State(initialValue: sleepStore)
        _flexTime = State(initialValue: .makeForApp(calendarStore, sleepStore, notificationScheduler))
        let destinationRequests = AppDestinationRequests()
        _destinationRequests = State(initialValue: destinationRequests)
        Self.registerIntentDependencies(countdowns, notesLibrary, noteNavigator, destinationRequests)
        #if os(macOS)
        _menuBarAgenda = State(initialValue: .started(with: calendarStore))
        #endif
    }

    private static func registerIntentDependencies(
        _ countdowns: EventCountdownManager,
        _ notesLibrary: NotesLibrary,
        _ noteNavigator: NoteNavigator,
        _ destinationRequests: AppDestinationRequests
    ) {
        AppDependencyManager.shared.add(dependency: countdowns)
        AppDependencyManager.shared.add(dependency: notesLibrary)
        AppDependencyManager.shared.add(dependency: noteNavigator)
        AppDependencyManager.shared.add(dependency: destinationRequests)
    }

    var body: some Scene {
        WindowGroup(id: Self.mainWindowIdentifier) {
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
                .environment(leaveAlerts)
            .environment(wakeUpAlarms)
                .environment(wakeUpAlarms)
                .environment(standaloneAlarms)
                .environment(notificationNavigator)
                .environment(weatherStore)
            .environment(travelTimeStore)
                .environment(travelTimeStore)
                .environment(sleepStore)
                .refreshesSleep(sleepStore)
                .environment(flexTime)
                .environment(medicationStore)
                .refreshesMedications(medicationStore)
                .notificationReplanTriggers(notificationScheduler)
                .replansNotificationsOnLinkedNoteChanges(notificationScheduler, library: notesLibrary)
                .opensNotesFromSpotlight(library: notesLibrary, navigator: noteNavigator)
                .opensNoteDeepLinks(library: notesLibrary, navigator: noteNavigator)
                .opensMeetingJoinDeepLinks()
                .environment(searchIndexer)
                .followsSystemTime(systemTime)
                .environment(undoCoordinator)
                .environment(undoToastHosts)
                .reloadsWidgets(on: calendarStore)
                .publishesEventNoteDigests(from: notesLibrary, events: calendarStore)
                .environment(countdowns)
                .reconcilesCountdowns(countdowns, with: calendarStore)
                .task(id: calendarStore.contentRevision) {
                    await noteLinkMaintenance.checkLinkedEvents()
                }
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
        #if os(macOS)
        .defaultSize(width: 1100, height: 760)
        #endif
        .notificationRefreshTask(notificationScheduler)
        .commands {
            if PlatformCapabilities.current.supports(.calendarViewMenuCommands) {
                CalendarViewCommands()
            }
            TimelineZoomCommands()
        }
        #if os(macOS)
        Settings {
            SettingsWindow()
            .environment(\.platformCapabilities, .current)
            .environment(calendarStore)
            .environment(notesLibrary)
            .environment(workWeekPreferences)
            .environment(permissionCenter)
            .environment(notificationScheduler)
            .environment(arrivalAlerts)
            .environment(leaveAlerts)
            .environment(wakeUpAlarms)
            .environment(searchIndexer)
            .environment(weatherStore)
            .environment(travelTimeStore)
            .environment(sleepStore)
            .environment(flexTime)
            .environment(medicationStore)
            .followsSystemTime(systemTime)
        }
        FolioMenuBarExtra(
            agenda: menuBarAgenda,
            calendarStore: calendarStore,
            destinationRequests: destinationRequests,
            undoCoordinator: undoCoordinator,
            systemTime: systemTime
        )
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
        if arguments.contains(EventKitDataSource.multiCalendarDataLaunchArgument) {
            try? await EventKitDataSource.shared.seedMultiCalendarData()
        }
        if arguments.contains(EventKitDataSource.stressDataLaunchArgument) {
            try? await EventKitDataSource.shared.seedStressData()
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
        if arguments.contains(LeaveAlertCenter.leaveTestLaunchArgument),
           let reference = try? EventKitDataSource.shared.seedArrivalTestEvent() {
            await leaveAlerts.setEnabled(true, for: reference)
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
        await ScreenshotSampleSeeder.seedIfRequested(
            arguments: arguments,
            calendarStore: calendarStore,
            notesLibrary: notesLibrary,
            standaloneAlarms: standaloneAlarms,
            notificationScheduler: notificationScheduler
        )
        await SleepSampleDataSeeder.seedIfRequested(into: sleepStore, arguments: arguments)
        #endif
    }
}
