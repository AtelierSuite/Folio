import Planner
import SwiftUI

struct CalendarTimelineContainer: View {
    @Environment(CalendarStore.self) private var store
    let days: TimelineDays
    @State private var entries: [TimelineEntry] = []

    var body: some View {
        CalendarTimelineView(entries: entries, days: days)
            .task(id: LoadKey(revision: store.contentRevision, span: days.span)) {
                await load()
            }
    }

    private func load() async {
        guard let span = days.span else { return }
        async let events = store.events(in: span)
        async let reminders = store.reminders(in: span)
        entries = await events.map(TimelineEntry.init(event:)) + reminders.compactMap { TimelineEntry(reminder: $0) }
    }

    private struct LoadKey: Equatable {
        let revision: Int
        let span: DateInterval?
    }
}
