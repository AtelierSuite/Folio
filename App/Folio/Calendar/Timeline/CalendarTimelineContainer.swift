import Planner
import SwiftUI

struct CalendarTimelineContainer: View {
    @Environment(CalendarStore.self) private var store
    let days: TimelineDays
    var excludedCalendarIdentifiers: Set<String> = []
    @State private var entries: [TimelineEntry] = []

    var body: some View {
        CalendarTimelineView(entries: entries, days: days)
            .task(id: LoadKey(
                revision: store.contentRevision, span: days.span, excluded: excludedCalendarIdentifiers
            )) {
                await load()
            }
    }

    private func load() async {
        guard let span = days.span else { return }
        async let events = store.events(in: span)
        async let reminders = store.reminders(in: span)
        let shownEvents = await events.filter { !excludedCalendarIdentifiers.contains($0.calendarIdentifier) }
        let shownReminders = await reminders.filter { !excludedCalendarIdentifiers.contains($0.listIdentifier) }
        entries = shownEvents.map(TimelineEntry.init(event:))
            + shownReminders.compactMap { TimelineEntry(reminder: $0) }
    }

    private struct LoadKey: Equatable {
        let revision: Int
        let span: DateInterval?
        let excluded: Set<String>
    }
}
