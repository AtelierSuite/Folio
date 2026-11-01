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
                ForEach(CalendarAccountGroup.groups(calendars: calendars, lists: lists)) { group in
                    Section(group.title) {
                        ForEach(group.calendars) { calendar in
                            CalendarKindLabel(calendar: calendar)
                                .tag(Optional(calendar.id))
                        }
                    }
                }
            }
            .pickerStyle(.inline)
        }
        .accessibilityIdentifier("Search.Filter.Calendar")
    }
}
