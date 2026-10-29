import Planner
import SwiftUI

struct CalendarTimelineContainer<Accessory: View>: View {
    @Environment(CalendarStore.self) private var store
    @Environment(CalendarNavigation.self) private var navigation
    @Environment(\.platformCapabilities) private var capabilities
    let days: TimelineDays
    let pageStep: CalendarPageStep
    let excludedCalendarIdentifiers: Set<String>
    let isPagingEnabled: Bool
    let accessory: Accessory
    @State private var entries: [TimelineEntry] = []
    @State private var eventsByEntryIdentifier: [String: CalendarEvent] = [:]
    @State private var selectedEvent: CalendarEvent?
    @State private var events: [CalendarEvent] = []
    @State private var weather = WeatherSnapshot.empty
    @State private var zoom: TimelineZoomController

    init(
        days: TimelineDays,
        pageStep: CalendarPageStep,
        zoomScope: TimelineZoomScope,
        excludedCalendarIdentifiers: Set<String> = [],
        isPagingEnabled: Bool = true,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.days = days
        self.pageStep = pageStep
        self.excludedCalendarIdentifiers = excludedCalendarIdentifiers
        self.isPagingEnabled = isPagingEnabled
        self.accessory = accessory()
        _zoom = State(initialValue: TimelineZoomController(storageKey: TimelineSettings.zoomKey(for: zoomScope)))
    }

    var body: some View {
        VStack(spacing: 0) {
            accessory
            CalendarTimelineView(
                entries: entries,
                days: days,
                zoom: zoom,
                layers: CalendarTimelineOverlays(capabilities: capabilities, weather: weather).layers(for: days),
                onSelectEntry: select
            )
            .environment(\.weatherSnapshot, weather)
            WeatherAttributionFooter(snapshot: weather)
        }
        .horizontalPaging(isEnabled: isPagingEnabled && !zoom.isPinching) { direction in
            navigation.page(by: pageStep, toward: direction)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                TimelineZoomMenu(zoom: zoom)
            }
        }
        .focusedSceneValue(\.timelineZoom, zoom)
        .task(id: LoadKey(
            revision: store.contentRevision, span: days.span, excluded: excludedCalendarIdentifiers
        )) {
            await load()
        }
        .loadsWeather(
            for: days.intervals, calendar: days.calendar, events: events, detail: .dailyAndHourly, into: $weather
        )
        .eventDetailSheet(item: $selectedEvent)
    }

    private func select(_ entry: TimelineEntry) {
        selectedEvent = eventsByEntryIdentifier[entry.id]
    }

    private func load() async {
        guard let span = days.span else { return }
        async let events = store.events(in: span)
        async let reminders = store.reminders(in: span)
        let shownEvents = await events.filter { !excludedCalendarIdentifiers.contains($0.calendarIdentifier) }
        let shownReminders = await reminders.filter { !excludedCalendarIdentifiers.contains($0.listIdentifier) }
        eventsByEntryIdentifier = Dictionary(shownEvents.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        self.events = shownEvents
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
        zoomScope: TimelineZoomScope,
        excludedCalendarIdentifiers: Set<String> = [],
        isPagingEnabled: Bool = true
    ) {
        self.init(
            days: days,
            pageStep: pageStep,
            zoomScope: zoomScope,
            excludedCalendarIdentifiers: excludedCalendarIdentifiers,
            isPagingEnabled: isPagingEnabled
        ) { EmptyView() }
    }
}
