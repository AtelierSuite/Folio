import Planner
import SwiftUI

struct CalendarMonthPageView: View {
    @Environment(CalendarStore.self) private var store
    @AppStorage(MonthSettings.showsWeekNumbersKey) private var showsWeekNumbers = false
    @ScaledMetric(relativeTo: .caption2) private var weekNumberWidth: CGFloat = 22
    let grid: MonthGrid
    let onSelectDay: (MonthDay) -> Void
    @State private var buckets = MonthDayBuckets.empty

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
                    onSelectDay: onSelectDay
                )
                .frame(maxHeight: .infinity)
                Divider()
            }
        }
        .task(id: LoadKey(revision: store.contentRevision, span: grid.span)) {
            await load()
        }
    }

    private func load() async {
        guard let span = grid.span else { return }
        async let events = store.events(in: span)
        async let reminders = store.reminders(in: span)
        let entries = await events.map(TimelineEntry.init(event:))
            + reminders.compactMap { TimelineEntry(reminder: $0, calendar: grid.calendar) }
        buckets = MonthDayBuckets(grid: grid, entries: entries)
    }

    private struct LoadKey: Equatable {
        let revision: Int
        let span: DateInterval?
    }
}
