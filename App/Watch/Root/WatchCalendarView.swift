import Planner
import SwiftUI

struct WatchCalendarView: View {
    @AppStorage("WatchViewMode") private var mode = WatchViewMode.timeline
    @State private var firstDay = Calendar.current.startOfDay(for: .now)
    @State private var isPickingMode = false

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .navigationDestination(for: CalendarEvent.self) { event in
                    WatchEventDetailView(event: event)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            isPickingMode = true
                        } label: {
                            Label(mode.title, systemImage: mode.systemImage)
                        }
                    }
                    if mode != .timeline {
                        WatchDayPagerToolbar(firstDay: $firstDay, step: mode.dayCount)
                    }
                }
                .sheet(isPresented: $isPickingMode) {
                    WatchViewModePicker(mode: $mode)
                }
        }
        .onOpenURL(perform: open)
    }

    @ViewBuilder
    private var content: some View {
        switch mode {
        case .timeline:
            WatchTimelineView()
        case .day, .twoDays:
            WatchDayGridScreen(firstDay: firstDay, dayCount: mode.dayCount)
        }
    }

    private var title: String {
        switch mode {
        case .timeline: mode.title
        case .day: firstDay.formatted(.dateTime.weekday(.abbreviated).day())
        case .twoDays: firstDay.formatted(.dateTime.month(.abbreviated).day())
        }
    }

    private func open(_ url: URL) {
        guard case .calendarDay(let date, _) = CalendarDeepLink.destination(from: url) else { return }
        firstDay = Calendar.current.startOfDay(for: date)
        if mode == .timeline {
            mode = .day
        }
    }
}
