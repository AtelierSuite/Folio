import Planner
import SwiftUI

struct CalendarTimelineContainer<Accessory: View>: View {
    @Environment(CalendarStore.self) var store
    @Environment(UndoCoordinator.self) var undoCoordinator
    @Environment(CalendarNavigation.self) var navigation
    @Environment(\.platformCapabilities) private var capabilities
    @AppStorage(DragSettings.snapMinutesKey) var snapMinutes = DragSettings.defaultSnapMinutes
    @AppStorage(SecondaryTimeZoneSettings.isEnabledKey, store: AppGroup.userDefaults)
    var showsSecondaryTimeZone = false
    @AppStorage(SecondaryTimeZoneSettings.identifierKey, store: AppGroup.userDefaults)
    var secondaryTimeZoneIdentifier = ""
    let days: TimelineDays
    let pageStep: CalendarPageStep
    let excludedCalendarIdentifiers: Set<String>
    let isPagingEnabled: Bool
    let accessory: Accessory
    @State private var entries: [TimelineEntry] = []
    @State var eventsByEntryIdentifier: [String: CalendarEvent] = [:]
    @State var remindersByEntryIdentifier: [String: ReminderItem] = [:]
    @State var drag = TimelineDragController()
    @State var dropHandler = CalendarDropHandler()
    @State var dragSource: CalendarDragSource?
    @State private var openedReminder: ReminderItem?
    @State private var eventActionsController = EventActionsController()
    @State private var events: [CalendarEvent] = []
    @State private var weather = WeatherSnapshot.empty
    @State var zoom: TimelineZoomController

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
                layers: CalendarTimelineOverlays(capabilities: capabilities, weather: weather).layers(for: days)
                    + secondaryTimeZoneLayers,
                onSelectEntry: select
            )
            .environment(drag)
            .environment(\.weatherSnapshot, weather)
            .reminderCompletion(
                undoCoordinator: undoCoordinator, remindersByEntryIdentifier: remindersByEntryIdentifier
            )
            WeatherAttributionFooter(snapshot: weather)
        }
        .horizontalPaging(isEnabled: isPagingEnabled && !zoom.isPinching && !drag.isActive) { direction in
            navigation.page(by: pageStep, toward: direction)
        }
        .modifier(dragHandling)
        .toolbar {
            ToolbarItem(placement: .secondaryAction) {
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
        .eventActionsHost(events: events, controller: eventActionsController) { drag.suppressesSelection }
        .onAppear {
            drag.onReleaseInPlace = { entry in
                guard !capabilities.usesPointerSelection, let event = eventsByEntryIdentifier[entry.id] else { return }
                eventActionsController.selectedEventID = event.id
                eventActionsController.cardMenuEventID = event.id
            }
        }
        .sheet(item: $openedReminder) { reminder in
            ReminderEditorView(reminder: reminder)
        }
    }

    private func select(_ entry: TimelineEntry) {
        guard !drag.suppressesSelection else { return }
        openedReminder = remindersByEntryIdentifier[entry.id]
    }

    func load() async {
        guard let span = days.span else { return }
        async let events = store.events(in: span)
        async let reminders = store.reminders(in: span, calendar: days.calendar)
        let shownEvents = await events.filter { !excludedCalendarIdentifiers.contains($0.calendarIdentifier) }
        let shownReminders = await reminders.filter { !excludedCalendarIdentifiers.contains($0.listIdentifier) }
        eventsByEntryIdentifier = Dictionary(shownEvents.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        remindersByEntryIdentifier = Dictionary(timelineEntriesFor: shownReminders)
        self.events = shownEvents
        entries = shownEvents.map(TimelineEntry.init(event:))
            + shownReminders.compactMap { TimelineEntry(reminder: $0, calendar: days.calendar) }
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
