#if os(macOS)
import Planner
import SwiftUI

/// Today's events and reminders on a fixed-scale time grid. Clicking one opens it in the main window.
struct MenuBarTodayTimeline: View {
    @Environment(CalendarStore.self) private var store
    @Environment(UndoCoordinator.self) private var undoCoordinator
    let onOpen: (AppDestination) -> Void
    private let strip: TimelineStrip
    @State private var position: ScrollPosition
    @State private var layout: TimelineLayout
    @State private var eventsByEntryIdentifier: [String: CalendarEvent] = [:]
    @State private var remindersByEntryIdentifier: [String: ReminderItem] = [:]

    init(day: Date, calendar: Calendar = .current, onOpen: @escaping (AppDestination) -> Void) {
        self.onOpen = onOpen
        let strip = TimelineStrip(unit: .day, around: day, window: SlidingPageWindow(radius: 0), calendar: calendar)
        self.strip = strip
        _position = State(initialValue: ScrollPosition(id: strip.pageStart(containing: day), anchor: .leading))
        _layout = State(initialValue: TimelineLayoutEngine(days: strip.days).layout([]))
    }

    var body: some View {
        CalendarTimelineView(
            layout: layout,
            pages: TimelinePages(strip: strip, columnsOnScreen: 1),
            position: $position,
            hourHeight: 44,
            showsDayLabels: false,
            initialHour: initialHour,
            onSelectEntry: open
        )
        .reminderCompletion(undoCoordinator: undoCoordinator, remindersByEntryIdentifier: remindersByEntryIdentifier)
        .task(id: store.contentRevision) {
            await load()
        }
    }

    private var initialHour: Double {
        let hour = strip.calendar.component(.hour, from: .now)
        return Double(max(hour - 1, 0))
    }

    private func open(_ entry: TimelineEntry) {
        if let event = eventsByEntryIdentifier[entry.id] {
            onOpen(.calendarDay(event.startDate, item: event.reference))
        } else if let reminder = remindersByEntryIdentifier[entry.id] {
            onOpen(.calendarDay(reminder.scheduledDate ?? entry.start, item: reminder.reference))
        }
    }

    private func load() async {
        guard let span = strip.days.span else { return }
        async let events = store.events(in: span)
        async let reminders = store.reminders(in: span, calendar: strip.calendar)
        let (shownEvents, shownReminders) = await (events, reminders)
        guard !Task.isCancelled else { return }
        eventsByEntryIdentifier = Dictionary(shownEvents.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        remindersByEntryIdentifier = Dictionary(timelineEntriesFor: shownReminders)
        let entries = EventDuplicateDetector(calendar: strip.calendar).groups(in: shownEvents)
            .map(TimelineEntry.init(group:))
            + shownReminders.compactMap { TimelineEntry(reminder: $0, calendar: strip.calendar) }
        layout = TimelineLayoutEngine(days: strip.days).layout(entries)
    }
}
#endif
