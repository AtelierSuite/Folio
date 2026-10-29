import Planner
import SwiftUI

struct CalendarMultiDayView: View {
    @Environment(CalendarNavigation.self) private var navigation
    var dayCount = 3

    var body: some View {
        CalendarTimelineContainer(
            days: TimelineDays(startingOn: navigation.selectedDate, count: dayCount, calendar: navigation.calendar),
            pageStep: .day
        )
    }
}
