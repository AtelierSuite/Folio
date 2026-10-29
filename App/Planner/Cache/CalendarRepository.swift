import Foundation

public actor CalendarRepository {
    private let source: any CalendarDataSource
    private let policy: CacheWindowPolicy
    private var eventWindow: CachedWindow<CalendarEvent>?
    private var reminderWindow: CachedWindow<ReminderItem>?
    private var generation = 0

    public init(source: any CalendarDataSource, policy: CacheWindowPolicy = CacheWindowPolicy()) {
        self.source = source
        self.policy = policy
    }

    public func events(in interval: DateInterval) async -> [CalendarEvent] {
        if let eventWindow, eventWindow.covers(interval) {
            return eventWindow.items.filter { $0.overlaps(interval) }
        }
        let fetchGeneration = generation
        let window = policy.window(around: interval)
        let items = await source.events(in: window)
        if fetchGeneration == generation {
            eventWindow = CachedWindow(interval: window, items: items)
        }
        return items.filter { $0.overlaps(interval) }
    }

    public func reminders(in interval: DateInterval) async -> [ReminderItem] {
        await reminders(around: interval).filter { $0.isDue(in: interval) }
    }

    /// Every incomplete reminder, dated or not, plus those completed in a window around `interval`.
    public func reminders(around interval: DateInterval) async -> [ReminderItem] {
        if let reminderWindow, reminderWindow.covers(interval) {
            return reminderWindow.items
        }
        let fetchGeneration = generation
        let window = policy.window(around: interval)
        let items = await source.reminders(completedIn: window)
        if fetchGeneration == generation {
            reminderWindow = CachedWindow(interval: window, items: items)
        }
        return items
    }

    public func invalidate() {
        generation += 1
        eventWindow = nil
        reminderWindow = nil
    }

    public func reload(visible interval: DateInterval) async {
        invalidate()
        async let events = events(in: interval)
        async let reminders = reminders(in: interval)
        _ = await (events, reminders)
    }
}
