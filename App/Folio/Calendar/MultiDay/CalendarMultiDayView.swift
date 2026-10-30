import Planner
import SwiftUI

struct CalendarMultiDayView: View {
    @Environment(CalendarNavigation.self) private var navigation
    @AppStorage("Calendar.MultiDayCount") private var dayCount: MultiDayCount = .three

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
            ToolbarItem(placement: .primaryAction) {
                MultiDayCountPicker(dayCount: $dayCount)
            }
        }
    }
}
