import Planner
import SwiftUI

struct CalendarMultiDayView: View {
    @Environment(CalendarNavigation.self) private var navigation
    @AppStorage("Calendar.MultiDayCount") private var dayCount: MultiDayCount = .three
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    var body: some View {
        CalendarTimelineContainer(
            unit: .day,
            columnsOnScreen: dayCount.rawValue,
            initialDate: navigation.selectedDate,
            calendar: navigation.calendar,
            pageStep: .day,
            zoomScope: .multiDay
        )
        .toolbar {
            if !isCompact {
                ToolbarItem(placement: .primaryAction) {
                    MultiDayCountPicker(dayCount: $dayCount)
                }
            }
        }
    }

    private var isCompact: Bool {
        #if os(iOS)
        horizontalSizeClass == .compact
        #else
        false
        #endif
    }
}
