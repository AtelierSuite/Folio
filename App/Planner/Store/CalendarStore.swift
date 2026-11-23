import Foundation
import Observation

@MainActor
@Observable
public final class CalendarStore {
    public private(set) var eventAuthorization: CalendarAuthorizationStatus
    public private(set) var reminderAuthorization: CalendarAuthorizationStatus
    public private(set) var eventCalendars: [PlannerCalendar] = []
    public private(set) var reminderLists: [PlannerCalendar] = []
    public internal(set) var hiddenCalendarIdentifiers: Set<String>
    public internal(set) var hiddenInvitationIdentifiers: Set<String>
    public internal(set) var hidesDeclinedEvents: Bool
    public internal(set) var chosenEventCalendarIdentifier: String?
    public internal(set) var chosenReminderListIdentifier: String?
    public internal(set) var contentRevision = 0
    public internal(set) var duplicateExcludedCalendarIdentifiers =
        DuplicateDetectionSettings.shared.excludedCalendarIdentifiers
    public internal(set) var markedBirthdayCalendarIdentifiers = BirthdaySettings.shared.markedCalendarIdentifiers
    public internal(set) var overdueReminderPolicy: OverdueReminderPolicy
    @ObservationIgnored var pendingRemovals: [UUID: PendingRemoval] = [:]
    @ObservationIgnored var pendingEventEdits: [UUID: PendingEventEdit] = [:]

    @ObservationIgnored let source: any CalendarDataSource
    @ObservationIgnored let repository: CalendarRepository
    @ObservationIgnored let visibilityStorage: CalendarVisibilityStorage
    @ObservationIgnored let reminderSettings: ReminderSettings
    @ObservationIgnored let flexTimeStorage: FlexTimeStorage
    @ObservationIgnored let reminderNotifications: any ReminderNotificationDismissing
    @ObservationIgnored let now: @Sendable () -> Date
    @ObservationIgnored var visibleInterval: DateInterval?
    @ObservationIgnored private var changeObservation: Task<Void, Never>?
    @ObservationIgnored var ownChangeNoticeDeadline: ContinuousClock.Instant?
    @ObservationIgnored var storeChangeReload: Task<Void, Never>?
    @ObservationIgnored private var hasLoadedCalendars = false
    @ObservationIgnored private var calendarLoadGeneration = 0

    public init(
        source: any CalendarDataSource = EventKitDataSource.shared,
        policy: CacheWindowPolicy = CacheWindowPolicy(),
        visibilityStorage: CalendarVisibilityStorage = CalendarVisibilityStorage(),
        reminderSettings: ReminderSettings = ReminderSettings(),
        flexTimeStorage: FlexTimeStorage = FlexTimeStorage(),
        reminderNotifications: any ReminderNotificationDismissing = NoReminderNotificationDismisser(),
        now: @escaping @Sendable () -> Date = { .now }
    ) {
        self.source = source
        self.repository = CalendarRepository(source: source, policy: policy)
        self.visibilityStorage = visibilityStorage
        self.reminderSettings = reminderSettings
        self.flexTimeStorage = flexTimeStorage
        self.reminderNotifications = reminderNotifications
        self.now = now
        overdueReminderPolicy = reminderSettings.overduePolicy
        eventAuthorization = source.authorizationStatus(for: .event)
        reminderAuthorization = source.authorizationStatus(for: .reminder)
        hiddenCalendarIdentifiers = visibilityStorage.hiddenCalendarIdentifiers
        hiddenInvitationIdentifiers = visibilityStorage.hiddenInvitationIdentifiers
        hidesDeclinedEvents = visibilityStorage.hidesDeclinedEvents
        chosenEventCalendarIdentifier = visibilityStorage.defaultEventCalendarIdentifier
        chosenReminderListIdentifier = visibilityStorage.defaultReminderListIdentifier
    }

    public func loadCalendarsIfNeeded() async {
        guard !hasLoadedCalendars else { return }
        await reloadCalendars()
    }

    public func startObservingChanges() {
        guard changeObservation == nil else { return }
        let changes = source.changes()
        changeObservation = Task { [weak self] in
            for await _ in changes {
                self?.noteStoreChange()
            }
        }
    }

    public func stopObservingChanges() {
        changeObservation?.cancel()
        changeObservation = nil
        storeChangeReload?.cancel()
        storeChangeReload = nil
    }

    public func events(in interval: DateInterval) async -> [CalendarEvent] {
        visibleInterval = interval
        return await delayedEvents(in: interval).filter(isShown)
    }

    func handleExternalChange() async {
        refreshAuthorization()
        await reloadCalendars()
        if let visibleInterval {
            await repository.reload(visible: visibleInterval)
        } else {
            await repository.invalidate()
        }
        contentRevision += 1
    }

    func refreshAuthorization() {
        eventAuthorization = source.authorizationStatus(for: .event)
        reminderAuthorization = source.authorizationStatus(for: .reminder)
    }

    func reloadCalendars() async {
        hasLoadedCalendars = true
        calendarLoadGeneration += 1
        let generation = calendarLoadGeneration
        let calendars = await Self.fetchCalendars(from: source)
        guard generation == calendarLoadGeneration else { return }
        if eventCalendars != calendars.events {
            eventCalendars = calendars.events
        }
        if reminderLists != calendars.reminders {
            reminderLists = calendars.reminders
        }
    }

    @concurrent
    nonisolated private static func fetchCalendars(
        from source: any CalendarDataSource
    ) async -> (events: [PlannerCalendar], reminders: [PlannerCalendar]) {
        (sorted(source.calendars(for: .event)), sorted(source.calendars(for: .reminder)))
    }

    nonisolated private static func sorted(_ calendars: [PlannerCalendar]) -> [PlannerCalendar] {
        calendars.sorted {
            ($0.sourceTitle.localizedLowercase, $0.title.localizedLowercase)
                < ($1.sourceTitle.localizedLowercase, $1.title.localizedLowercase)
        }
    }
}
