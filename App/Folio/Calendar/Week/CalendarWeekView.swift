import Planner
import SwiftUI

struct CalendarWeekView: View {
    @Environment(CalendarNavigation.self) private var navigation
    let isWorkWeek: Bool

    var body: some View {
        let weekStart = navigation.startOfWeek(containing: navigation.selectedDate)
        let start = isWorkWeek
            ? navigation.calendar.date(byAdding: .day, value: 1, to: weekStart) ?? weekStart
            : weekStart
        CalendarTimelineContainer(
            days: TimelineDays(startingOn: start, count: isWorkWeek ? 5 : 7, calendar: navigation.calendar)
        )
    }
}
