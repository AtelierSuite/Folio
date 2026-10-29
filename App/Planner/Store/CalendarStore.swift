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
    public internal(set) var contentRevision = 0

    @ObservationIgnored let source: any CalendarDataSource
    @ObservationIgnored let repository: CalendarRepository
    @ObservationIgnored let visibilityStorage: CalendarVisibilityStorage
    @ObservationIgnored private var visibleInterval: DateInterval?
    @ObservationIgnored private var changeObservation: Task<Void, Never>?

    public init(
        source: any CalendarDataSource = EventKitDataSource.shared,
        policy: CacheWindowPolicy = CacheWindowPolicy(),
        visibilityStorage: CalendarVisibilityStorage = CalendarVisibilityStorage()
    ) {
        self.source = source
        self.repository = CalendarRepository(source: source, policy: policy)
        self.visibilityStorage = visibilityStorage
        eventAuthorization = source.authorizationStatus(for: .event)
        reminderAuthorization = source.authorizationStatus(for: .reminder)
        hiddenCalendarIdentifiers = visibilityStorage.hiddenCalendarIdentifiers
        reloadCalendars()
    }

    public func startObservingChanges() {
        guard changeObservation == nil else { return }
        let changes = source.changes()
        changeObservation = Task { [weak self] in
            for await _ in changes {
                await self?.handleExternalChange()
            }
        }
    }

    public func stopObservingChanges() {
        changeObservation?.cancel()
        changeObservation = nil
    }

    public func events(in interval: DateInterval) async -> [CalendarEvent] {
        visibleInterval = interval
        let events = await repository.events(in: interval)
        return events.filter { !hiddenCalendarIdentifiers.contains($0.calendarIdentifier) }
    }

    public func reminders(in interval: DateInterval) async -> [ReminderItem] {
        visibleInterval = interval
        let reminders = await repository.reminders(in: interval)
        return reminders.filter { !hiddenCalendarIdentifiers.contains($0.listIdentifier) }
    }

    public func setCompleted(_ isCompleted: Bool, for reminder: ReminderItem) async throws {
        try await source.setCompleted(isCompleted, reminderIdentifier: reminder.reference.localIdentifier)
        await handleExternalChange()
    }

    func handleExternalChange() async {
        refreshAuthorization()
        reloadCalendars()
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

    func reloadCalendars() {
        eventCalendars = Self.sorted(source.calendars(for: .event))
        reminderLists = Self.sorted(source.calendars(for: .reminder))
    }

    private static func sorted(_ calendars: [PlannerCalendar]) -> [PlannerCalendar] {
        calendars.sorted {
            ($0.sourceTitle.localizedLowercase, $0.title.localizedLowercase)
                < ($1.sourceTitle.localizedLowercase, $1.title.localizedLowercase)
        }
    }
}
