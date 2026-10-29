import Planner
import SwiftUI

struct CalendarTimelineContainer<Accessory: View>: View {
    @Environment(CalendarStore.self) private var store
    @Environment(CalendarNavigation.self) private var navigation
    let days: TimelineDays
    let pageStep: CalendarPageStep
    let excludedCalendarIdentifiers: Set<String>
    let isPagingEnabled: Bool
    let accessory: Accessory
    @State private var entries: [TimelineEntry] = []

    init(
        days: TimelineDays,
        pageStep: CalendarPageStep,
        excludedCalendarIdentifiers: Set<String> = [],
        isPagingEnabled: Bool = true,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.days = days
        self.pageStep = pageStep
        self.excludedCalendarIdentifiers = excludedCalendarIdentifiers
        self.isPagingEnabled = isPagingEnabled
        self.accessory = accessory()
    }

    var body: some View {
        VStack(spacing: 0) {
            accessory
            CalendarTimelineView(entries: entries, days: days)
        }
        .horizontalPaging(isEnabled: isPagingEnabled) { direction in
            navigation.page(by: pageStep, toward: direction)
        }
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

extension CalendarTimelineContainer where Accessory == EmptyView {
    init(
        days: TimelineDays,
        pageStep: CalendarPageStep,
        excludedCalendarIdentifiers: Set<String> = [],
        isPagingEnabled: Bool = true
    ) {
        self.init(
            days: days,
            pageStep: pageStep,
            excludedCalendarIdentifiers: excludedCalendarIdentifiers,
            isPagingEnabled: isPagingEnabled
        ) { EmptyView() }
    }
}
