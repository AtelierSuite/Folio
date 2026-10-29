import Foundation

public struct WidgetSnapshotLoader: Sendable {
    private let source: any CalendarDataSource
    private let visibilityStorage: CalendarVisibilityStorage
    private let weatherReader: WidgetWeatherReader

    public init(
        source: any CalendarDataSource = EventKitDataSource.shared,
        visibilityStorage: CalendarVisibilityStorage = CalendarVisibilityStorage(),
        weatherReader: WidgetWeatherReader = WidgetWeatherReader()
    ) {
        self.source = source
        self.visibilityStorage = visibilityStorage
        self.weatherReader = weatherReader
    }

    public func load(
        _ request: WidgetSnapshotRequest,
        at now: Date,
        calendar: Calendar = .current
    ) async -> WidgetSnapshot {
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
            reminders: reminders.filter { listFilter.includes($0.listIdentifier) },
            weather: request.includesWeather ? weather(around: now, calendar: calendar) : [:]
        )
    }

    private func weather(around now: Date, calendar: Calendar) -> [Date: DailyWeather] {
        let today = calendar.startOfDay(for: now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today.addingTimeInterval(86_400)
        return weatherReader.dailyWeather(forDaysStarting: [today, tomorrow], calendar: calendar)
    }
}
