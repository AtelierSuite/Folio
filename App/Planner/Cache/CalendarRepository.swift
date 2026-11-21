import Foundation

public actor CalendarRepository {
    static let windowCapacity = 4

    private let source: any CalendarDataSource
    private let policy: CacheWindowPolicy
    private let eventWindows = WindowCache<CalendarEvent>(capacity: windowCapacity)
    private let completedReminderWindows = WindowCache<ReminderItem>(capacity: windowCapacity)
    private var incompleteReminders: [ReminderItem]?
    private var incompleteRemindersFetch: Task<[ReminderItem], Never>?

    public init(source: any CalendarDataSource, policy: CacheWindowPolicy = CacheWindowPolicy()) {
        self.source = source
        self.policy = policy
    }

    var cachedEventIntervals: [DateInterval] {
        eventWindows.intervals
    }

    public func events(in interval: DateInterval) async -> [CalendarEvent] {
        let source = source
        let events = await items(around: interval, in: eventWindows) { window in
            await source.events(in: window)
        }
        return events.filter { $0.overlaps(interval) }
    }

    private func completedReminders(around interval: DateInterval) async -> [ReminderItem] {
        let source = source
        return await items(around: interval, in: completedReminderWindows) { window in
            await source.completedReminders(in: window)
        }
    }

    public func reminders(in interval: DateInterval) async -> [ReminderItem] {
        await reminders(around: interval).filter { $0.isDue(in: interval) }
    }

    /// Every incomplete reminder, dated or not, plus those completed in a window around `interval`.
    public func reminders(around interval: DateInterval) async -> [ReminderItem] {
        async let incomplete = allIncompleteReminders()
        async let completed = completedReminders(around: interval)
        return await incomplete + completed
    }

    public func invalidate() {
        eventWindows.removeAll()
        completedReminderWindows.removeAll()
        incompleteReminders = nil
        incompleteRemindersFetch = nil
    }

    public func reload(visible interval: DateInterval) async {
        invalidate()
        async let events = events(in: interval)
        async let reminders = reminders(in: interval)
        _ = await (events, reminders)
    }

    private func items<Item: Sendable>(
        around interval: DateInterval,
        in cache: WindowCache<Item>,
        fetching fetchItems: @escaping @Sendable (DateInterval) async -> [Item]
    ) async -> [Item] {
        if let items = cache.items(covering: interval) { return items }
        if let fetch = cache.fetch(covering: interval) { return await fetch.value }
        let window = policy.window(around: interval)
        let fetch = Task { await fetchItems(window) }
        cache.begin(fetch, for: window)
        let items = await fetch.value
        cache.finish(fetch, for: window, items: items)
        return items
    }

    private func allIncompleteReminders() async -> [ReminderItem] {
        if let incompleteReminders { return incompleteReminders }
        if let incompleteRemindersFetch { return await incompleteRemindersFetch.value }
        let source = source
        let fetch = Task { await source.incompleteReminders() }
        incompleteRemindersFetch = fetch
        let reminders = await fetch.value
        if incompleteRemindersFetch == fetch {
            incompleteRemindersFetch = nil
            incompleteReminders = reminders
        }
        return reminders
    }
}
