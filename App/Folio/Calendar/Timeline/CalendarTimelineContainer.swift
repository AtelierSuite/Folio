import Planner
import SwiftUI

struct CalendarTimelineContainer<Accessory: View>: View {
    @Environment(CalendarStore.self) var store
    @Environment(UndoCoordinator.self) var undoCoordinator
    @Environment(CalendarNavigation.self) var navigation
    @Environment(\.platformCapabilities) private var capabilities
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @AppStorage(DragSettings.snapMinutesKey) var snapMinutes = DragSettings.defaultSnapMinutes
    @AppStorage(WeatherNightSettings.shadesNightKey) var shadesNight = true
    @AppStorage(SecondaryTimeZoneSettings.isEnabledKey, store: AppGroup.userDefaults)
    var showsSecondaryTimeZone = false
    @AppStorage(SecondaryTimeZoneSettings.identifierKey, store: AppGroup.userDefaults)
    var secondaryTimeZoneIdentifier = ""
    let unit: TimelineStrip.Unit
    let requestedColumnsOnScreen: Int?
    let pageStep: CalendarPageStep
    let excludedCalendarIdentifiers: Set<String>
    let accessory: Accessory
    @State var strip: TimelineStrip
    @State var position: ScrollPosition
    @State var scrollPhase = ScrollPhase.idle
    @State var settledPage: Date
    @State var stripLayout: TimelineLayout
    @State var entries: [TimelineEntry] = []
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
        unit: TimelineStrip.Unit,
        columnsOnScreen: Int? = nil,
        initialDate: Date,
        calendar: Calendar,
        pageStep: CalendarPageStep,
        zoomScope: TimelineZoomScope,
        excludedCalendarIdentifiers: Set<String> = [],
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.unit = unit
        requestedColumnsOnScreen = columnsOnScreen
        self.pageStep = pageStep
        self.excludedCalendarIdentifiers = excludedCalendarIdentifiers
        self.accessory = accessory()
        let strip = Self.strip(unit: unit, columnsOnScreen: columnsOnScreen, around: initialDate, calendar: calendar)
        let page = strip.pageStart(containing: initialDate)
        _strip = State(initialValue: strip)
        _position = State(initialValue: ScrollPosition(id: page, anchor: .leading))
        _settledPage = State(initialValue: page)
        _stripLayout = State(initialValue: TimelineLayoutEngine(days: strip.days).layout([]))
        _zoom = State(initialValue: TimelineZoomController(storageKey: TimelineSettings.zoomKey(for: zoomScope)))
    }

    var body: some View {
        VStack(spacing: 0) {
            accessory
            CalendarTimelineView(
                layout: stripLayout,
                pages: TimelinePages(strip: strip, columnsOnScreen: columnsOnScreen),
                position: $position,
                zoom: zoom,
                layers: CalendarTimelineOverlays(
                    capabilities: capabilities, weather: weather, shadesNight: shadesNight
                ).layers(for: strip.days)
                    + secondaryTimeZoneLayers,
                onSelectEntry: select,
                onScrollPhaseChange: handleScrollPhase
            )
            .environment(drag)
            .environment(\.weatherSnapshot, weather)
            .reminderCompletion(
                undoCoordinator: undoCoordinator, remindersByEntryIdentifier: remindersByEntryIdentifier
            )
        }
        .modifier(dragHandling)
        .modifier(scrollSync)
        .toolbar {
            ToolbarItem(placement: .secondaryAction) {
                TimelineZoomMenu(zoom: zoom)
            }
        }
        .focusedSceneValue(\.timelineZoom, zoom)
        .task(id: LoadKey(
            revision: store.contentRevision, span: strip.days.span, excluded: excludedCalendarIdentifiers
        )) {
            await load()
        }
        .loadsWeather(
            for: strip.intervals(aroundPage: settledPage, pageRadius: weatherPageRadius),
            calendar: strip.calendar, events: events, detail: .dailyAndHourly, into: $weather
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

    private var weatherPageRadius: Int {
        strip.unit == .day ? columnsOnScreen + 1 : 1
    }

    private func select(_ entry: TimelineEntry) {
        guard !drag.suppressesSelection else { return }
        openedReminder = remindersByEntryIdentifier[entry.id]
    }

    func load() async {
        guard let span = strip.days.span else { return }
        let calendar = strip.calendar
        async let events = store.events(in: span)
        async let reminders = store.reminders(in: span, calendar: calendar)
        let shownEvents = await events.filter { !excludedCalendarIdentifiers.contains($0.calendarIdentifier) }
        let shownReminders = await reminders.filter { !excludedCalendarIdentifiers.contains($0.listIdentifier) }
        guard !Task.isCancelled else { return }
        eventsByEntryIdentifier = Dictionary(shownEvents.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        remindersByEntryIdentifier = Dictionary(timelineEntriesFor: shownReminders)
        self.events = shownEvents
        entries = shownEvents.map(TimelineEntry.init(event:))
            + shownReminders.compactMap { TimelineEntry(reminder: $0, calendar: calendar) }
        relayout()
    }

    func relayout() {
        stripLayout = TimelineLayoutEngine(days: strip.days).layout(entries)
    }

    private struct LoadKey: Equatable {
        let revision: Int
        let span: DateInterval?
        let excluded: Set<String>
    }
}

extension CalendarTimelineContainer where Accessory == EmptyView {
    init(
        unit: TimelineStrip.Unit,
        columnsOnScreen: Int? = nil,
        initialDate: Date,
        calendar: Calendar,
        pageStep: CalendarPageStep,
        zoomScope: TimelineZoomScope,
        excludedCalendarIdentifiers: Set<String> = []
    ) {
        self.init(
            unit: unit,
            columnsOnScreen: columnsOnScreen,
            initialDate: initialDate,
            calendar: calendar,
            pageStep: pageStep,
            zoomScope: zoomScope,
            excludedCalendarIdentifiers: excludedCalendarIdentifiers
        ) { EmptyView() }
    }
}
