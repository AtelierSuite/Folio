import Planner
import SwiftUI

struct CalendarMultiDayView: View {
    @Environment(CalendarNavigation.self) private var navigation
    @AppStorage("Calendar.MultiDayCount") private var dayCount: MultiDayCount = .three

    var body: some View {
        CalendarTimelineContainer(
            days: TimelineDays(
                startingOn: navigation.selectedDate,
                count: dayCount.rawValue,
                calendar: navigation.calendar
            ),
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
