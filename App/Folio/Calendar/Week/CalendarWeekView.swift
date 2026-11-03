import Planner
import SwiftUI

struct CalendarWeekView: View {
    @Environment(CalendarNavigation.self) private var navigation
    @Environment(WorkWeekPreferences.self) private var workWeek
    @Environment(\.platformCapabilities) private var capabilities
    @AppStorage(CalendarWeekLayout.storageKey) private var layout: CalendarWeekLayout = .allDays
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    let isWorkWeek: Bool

    var body: some View {
        Group {
            switch layout {
            case .allDays: allDays
            case .singleDay: CalendarWeekSingleDayView(isWorkWeek: isWorkWeek)
            }
        }
        .toolbar {
            if !isCompact && !capabilities.supports(.calendarViewMenuCommands) {
                ToolbarItem(placement: .primaryAction) {
                    CalendarWeekLayoutPicker(layout: $layout)
                        .pickerStyle(.menu)
                }
            }
        }
    }

    private var allDays: some View {
        CalendarTimelineContainer(
            unit: .week(workdays: isWorkWeek ? workWeek.workdays : nil),
            initialDate: navigation.selectedDate,
            calendar: navigation.calendar,
            pageStep: .week,
            zoomScope: isWorkWeek ? .workWeek : .week,
            excludedCalendarIdentifiers: isWorkWeek ? workWeek.excludedCalendarIdentifiers : []
        )
    }

    private var isCompact: Bool {
        #if os(iOS)
        horizontalSizeClass == .compact
        #else
        false
        #endif
    }
}
