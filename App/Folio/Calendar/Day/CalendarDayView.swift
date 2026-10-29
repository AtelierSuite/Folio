import Planner
import SwiftUI

struct CalendarDayView: View {
    @Environment(CalendarNavigation.self) private var navigation

    var body: some View {
        CalendarTimelineContainer(
            days: TimelineDays(startingOn: navigation.selectedDate, count: 1, calendar: navigation.calendar)
        )
    }
}
