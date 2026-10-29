import Planner
import SwiftUI

struct SearchCalendarFilterMenu: View {
    @Environment(CalendarStore.self) private var store
    @Binding var filters: SearchFilters

    private var calendars: [PlannerCalendar] {
        filters.kind == .reminder ? [] : store.eventCalendars.filter(store.isVisible)
    }

    private var lists: [PlannerCalendar] {
        filters.kind == .event ? [] : store.reminderLists.filter(store.isVisible)
    }

    private var selectedCalendar: PlannerCalendar? {
        (calendars + lists).first { $0.id == filters.containerIdentifier }
    }

    var body: some View {
        SearchFilterChip(
            title: selectedCalendar?.title ?? String(localized: "Filter.Calendar.All", table: "Search"),
            systemImage: "tray.2",
            isActive: filters.containerIdentifier != nil
        ) {
            Picker(String(localized: "Filter.Calendar", table: "Search"), selection: $filters.containerIdentifier) {
                Text(String(localized: "Filter.Calendar.All", table: "Search")).tag(String?.none)
                if !calendars.isEmpty {
                    Section(String(localized: "Filter.Calendar.Calendars", table: "Search")) {
                        options(for: calendars)
                    }
                }
                if !lists.isEmpty {
                    Section(String(localized: "Filter.Calendar.Lists", table: "Search")) {
                        options(for: lists)
                    }
                }
            }
            .pickerStyle(.inline)
        }
        .accessibilityIdentifier("Search.Filter.Calendar")
    }

    private func options(for calendars: [PlannerCalendar]) -> some View {
        ForEach(calendars) { calendar in
            Text(calendar.title).tag(Optional(calendar.id))
        }
    }
}
