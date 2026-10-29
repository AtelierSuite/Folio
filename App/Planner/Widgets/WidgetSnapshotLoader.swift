import Foundation

public struct WidgetSnapshotLoader: Sendable {
    private let source: any CalendarDataSource
    private let visibilityStorage: CalendarVisibilityStorage

    public init(
        source: any CalendarDataSource = EventKitDataSource.shared,
        visibilityStorage: CalendarVisibilityStorage = CalendarVisibilityStorage()
    ) {
        self.source = source
        self.visibilityStorage = visibilityStorage
    }

    public func load(_ request: WidgetSnapshotRequest, at now: Date) async -> WidgetSnapshot {
        let hidden = visibilityStorage.hiddenCalendarIdentifiers
        let calendarFilter = WidgetCalendarFilter(selectedIdentifiers: request.calendars, hiddenIdentifiers: hidden)
        let listFilter = WidgetCalendarFilter(selectedIdentifiers: request.lists, hiddenIdentifiers: hidden)
        var events: [CalendarEvent] = []
        if let interval = request.eventInterval {
            events = await source.events(in: interval)
        }
        let reminders = request.includesReminders
            ? await source.reminders(completedIn: DateInterval(start: now, duration: 0))
            : []
        return WidgetSnapshot(
            eventAuthorization: source.authorizationStatus(for: .event),
            reminderAuthorization: source.authorizationStatus(for: .reminder),
            events: events.filter { calendarFilter.includes($0.calendarIdentifier) },
            reminders: reminders.filter { listFilter.includes($0.listIdentifier) }
        )
    }
}
