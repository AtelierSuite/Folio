import Foundation

public struct WidgetSnapshotLoader: Sendable {
    private static let eventsWithBadges = 3

    private let source: any CalendarDataSource
    private let visibilityStorage: CalendarVisibilityStorage
    private let weatherReader: WidgetWeatherReader
    private let alarmStorage: StandaloneAlarmStorage
    private let wakeUpSettings: WakeUpAlarmSettings
    private let eventNoteStore: EventNoteDigestStore
    private let badgeReader: any ContactBadgeReading
    private let medicationReader: WidgetMedicationReader
    private let leaveBySettings: LeaveBySettings

    public init(
        source: any CalendarDataSource = EventKitDataSource.shared,
        visibilityStorage: CalendarVisibilityStorage = CalendarVisibilityStorage(),
        weatherReader: WidgetWeatherReader = WidgetWeatherReader(),
        alarmStorage: StandaloneAlarmStorage = StandaloneAlarmStorage(),
        wakeUpSettings: WakeUpAlarmSettings = WakeUpAlarmSettings(),
        eventNoteStore: EventNoteDigestStore = EventNoteDigestStore(),
        badgeReader: any ContactBadgeReading = SystemContactBadgeReader(),
        medicationReader: WidgetMedicationReader = WidgetMedicationReader(),
        leaveBySettings: LeaveBySettings = LeaveBySettings()
    ) {
        self.source = source
        self.visibilityStorage = visibilityStorage
        self.weatherReader = weatherReader
        self.alarmStorage = alarmStorage
        self.wakeUpSettings = wakeUpSettings
        self.eventNoteStore = eventNoteStore
        self.badgeReader = badgeReader
        self.medicationReader = medicationReader
        self.leaveBySettings = leaveBySettings
    }

    public func load(
        _ request: WidgetSnapshotRequest,
        at now: Date,
        calendar: Calendar = .current
    ) async -> WidgetSnapshot {
        let hidden = visibilityStorage.hiddenCalendarIdentifiers
        let hiddenInvitations = visibilityStorage.hiddenInvitationIdentifiers
        let calendarFilter = WidgetCalendarFilter(selectedIdentifiers: request.calendars, hiddenIdentifiers: hidden)
        let listFilter = WidgetCalendarFilter(selectedIdentifiers: request.lists, hiddenIdentifiers: hidden)
        var events: [CalendarEvent] = []
        if let interval = request.eventInterval {
            events = await source.flexTimeEvents(in: interval)
        }
        let reminders = request.includesReminders
            ? await source.reminders(completedIn: DateInterval(start: now, duration: 0))
            : []
        let visibleEvents = EventDuplicateDetector(calendar: calendar)
            .groups(in: events.filter {
                calendarFilter.includes($0.calendarIdentifier) && !$0.isHiddenInvitation(among: hiddenInvitations)
            })
            .map(\.primary)
        let eventNotes = request.includesEventNotes ? eventNoteStore.digests : [:]
        let leaveByPlan = request.includesLeaveBy ? leaveBySettings.plan : nil
        let doses = request.includesMedications ? await medicationReader.dosesAwaitingAction(at: now) : []
        return WidgetSnapshot(
            eventAuthorization: source.authorizationStatus(for: .event),
            reminderAuthorization: source.authorizationStatus(for: .reminder),
            events: visibleEvents,
            reminders: reminders.filter { listFilter.includes($0.listIdentifier) },
            weather: request.includesWeather ? weather(around: now, calendar: calendar) : [:],
            alarmDates: request.includesAlarms ? alarmDates(after: now) : [],
            medicationDoses: doses,
            leaveByPlan: leaveByPlan,
            leaveByStatus: request.includesLeaveBy ? leaveBySettings.status : .off,
            leaveByRainChance: leaveByPlan.flatMap { rainChance(for: $0, in: visibleEvents, calendar: calendar) },
            eventNotes: eventNotes,
            contactBadges: badges(for: visibleEvents, withNotes: eventNotes, after: now)
        )
    }

    private func rainChance(
        for plan: LeaveByPlan,
        in events: [CalendarEvent],
        calendar: Calendar
    ) -> Double? {
        guard let event = events.first(where: { $0.reference.storageKey == plan.eventKey }) else { return nil }
        return weatherReader.hourlyWeather(at: plan.leaveDate(for: event), calendar: calendar)?.precipitationChance
    }

    private func badges(
        for events: [CalendarEvent],
        withNotes eventNotes: [String: EventNoteDigest],
        after now: Date
    ) -> [String: ContactBadge] {
        let upcoming = events
            .filter { $0.endDate > now && eventNotes[$0.reference.storageKey] != nil }
            .prefix(Self.eventsWithBadges)
        var badges: [String: ContactBadge] = [:]
        for participant in upcoming.flatMap(\.visibleAttendees) where badges[participant.id] == nil {
            badges[participant.id] = badgeReader.badge(for: participant)
        }
        return badges
    }

    private func alarmDates(after now: Date) -> [Date] {
        (alarmStorage.alarms.map(\.fireDate) + wakeUpSettings.upcomingFireDates).filter { $0 > now }
    }

    private func weather(around now: Date, calendar: Calendar) -> [Date: DailyWeather] {
        let today = calendar.startOfDay(for: now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today.addingTimeInterval(86_400)
        return weatherReader.dailyWeather(forDaysStarting: [today, tomorrow], calendar: calendar)
    }
}
