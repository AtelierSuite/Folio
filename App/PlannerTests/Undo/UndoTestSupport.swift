import Foundation
import Synchronization
import Testing
@testable import Planner

@MainActor
struct UndoTestContext {
    let source: FakeCalendarDataSource
    let store: CalendarStore
    let coordinator: UndoCoordinator
    let undoManager: UndoManager
    let week = DateInterval(start: Fixtures.date(2026, 10, 25), end: Fixtures.date(2026, 11, 1))

    init(
        events: [CalendarEvent] = [],
        reminders: [ReminderItem] = [],
        library: NotesLibrary? = nil,
        toastDuration: Duration = .seconds(60)
    ) throws {
        source = FakeCalendarDataSource(
            events: events,
            reminders: reminders,
            calendars: [Fixtures.plannerCalendar("work"), Fixtures.plannerCalendar("list-1", kind: .reminder)]
        )
        for event in events {
            source.state.withLock { $0.eventWriting.drafts[event.reference.localIdentifier] = Self.draft(of: event) }
        }
        let defaults = try #require(UserDefaults(suiteName: "UndoTests.\(UUID().uuidString)"))
        store = CalendarStore(
            source: source,
            policy: CacheWindowPolicy(paddingWeeks: 1, calendar: Fixtures.calendar),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults)
        )
        coordinator = UndoCoordinator(
            store: store, library: library, toastDuration: toastDuration, assistiveToastDuration: toastDuration
        )
        undoManager = UndoManager()
        undoManager.groupsByEvent = false
        coordinator.undoManager = undoManager
    }

    static func event(_ local: String, day: Int = 29, hour: Int = 9) -> CalendarEvent {
        FakeCalendarDataSource.event(
            from: draft(title: local, day: day, hour: hour), localIdentifier: local, occurrenceDate: nil
        )
    }

    static func series(_ local: String, days: ClosedRange<Int>) -> [CalendarEvent] {
        days.map { day in
            var occurrenceDraft = draft(title: local, day: day, hour: 9)
            occurrenceDraft.recurrence = EventRecurrence(frequency: .daily)
            return FakeCalendarDataSource.event(
                from: occurrenceDraft, localIdentifier: local, occurrenceDate: occurrenceDraft.startDate
            )
        }
    }

    static func draft(title: String, day: Int, hour: Int) -> EventDraft {
        let start = Fixtures.date(2026, 10, day, hour: hour)
        return EventDraft(
            title: title, calendarIdentifier: "work", startDate: start, endDate: start.addingTimeInterval(3600)
        )
    }

    static func draft(of event: CalendarEvent) -> EventDraft {
        EventDraft(
            title: event.title, calendarIdentifier: event.calendarIdentifier,
            startDate: event.startDate, endDate: event.endDate,
            recurrence: event.isRecurring ? EventRecurrence(frequency: .daily) : nil
        )
    }

    func visibleEventTitles() async -> [String] {
        await store.events(in: week).sorted { $0.startDate < $1.startDate }.map(\.title)
    }

    func visibleReminderTitles() async -> [String] {
        await store.reminders(in: week).map(\.title)
    }

    static func makeSource() -> FakeCalendarDataSource {
        FakeCalendarDataSource(events: [event("Lunch")], calendars: [Fixtures.plannerCalendar("work")])
    }

    static func makeStore(source: FakeCalendarDataSource, defaults: UserDefaults) -> CalendarStore {
        CalendarStore(source: source, visibilityStorage: CalendarVisibilityStorage(defaults: defaults))
    }

    var deleteCalls: [FakeEventWriting.Call] {
        source.eventWriteCalls.filter { if case .delete = $0 { true } else { false } }
    }

    /// Undo and redo run their EventKit work asynchronously after `UndoManager` returns.
    func undo() async {
        undoManager.undo()
        await coordinator.settle()
    }

    func redo() async {
        undoManager.redo()
        await coordinator.settle()
    }
}
