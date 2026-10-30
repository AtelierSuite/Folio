import Planner
import SwiftUI

struct CalendarMonthPageView: View {
    @Environment(CalendarStore.self) var store
    @Environment(UndoCoordinator.self) var undoCoordinator
    @AppStorage(MonthSettings.showsWeekNumbersKey) private var showsWeekNumbers = false
    @ScaledMetric(relativeTo: .caption2) private var weekNumberWidth: CGFloat = 22
    let grid: MonthGrid
    let onSelectDay: (MonthDay) -> Void
    @State private var buckets = MonthDayBuckets.empty
    @State private var events: [CalendarEvent] = []
    @State private var weather = WeatherSnapshot.empty
    @State var eventsByEntryIdentifier: [String: CalendarEvent] = [:]
    @State var remindersByEntryIdentifier: [String: ReminderItem] = [:]
    @State var dropHandler = CalendarDropHandler()

    var body: some View {
        VStack(spacing: 0) {
            CalendarMonthWeekdayHeaderView(
                grid: grid, showsWeekNumbers: showsWeekNumbers, weekNumberWidth: weekNumberWidth
            )
            Divider()
            ForEach(grid.weeks) { week in
                CalendarMonthWeekRowView(
                    week: week,
                    buckets: buckets,
                    calendar: grid.calendar,
                    showsWeekNumber: showsWeekNumbers,
                    weekNumberWidth: weekNumberWidth,
                    onSelectDay: onSelectDay,
                    onDrop: drop
                )
                .frame(maxHeight: .infinity)
                Divider()
            }
            WeatherAttributionFooter(snapshot: weather)
        }
        .environment(\.weatherSnapshot, weather)
        .reminderCompletion(undoCoordinator: undoCoordinator, remindersByEntryIdentifier: remindersByEntryIdentifier)
        .calendarDropDialogs(dropHandler)
        .eventActionsHost(events: events)
        .task(id: LoadKey(revision: store.contentRevision, span: grid.span)) {
            await load()
        }
        .loadsWeather(
            for: grid.weeks.flatMap(\.days).map(\.interval), calendar: grid.calendar, events: events,
            detail: .daily, into: $weather
        )
    }

    private func load() async {
        guard let span = grid.span else { return }
        async let loadedEvents = store.events(in: span)
        async let loadedReminders = store.reminders(in: span, calendar: grid.calendar)
        let events = await loadedEvents
        let reminders = await loadedReminders
        self.events = events
        eventsByEntryIdentifier = Dictionary(events.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        remindersByEntryIdentifier = Dictionary(timelineEntriesFor: reminders)
        let entries = events.map(TimelineEntry.init(event:))
            + reminders.compactMap { TimelineEntry(reminder: $0, calendar: grid.calendar) }
        buckets = MonthDayBuckets(grid: grid, entries: entries)
    }

    private struct LoadKey: Equatable {
        let revision: Int
        let span: DateInterval?
    }
}
