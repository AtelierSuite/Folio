import Planner
import SwiftUI

struct CalendarWeekView: View {
    @Environment(CalendarNavigation.self) private var navigation
    @Environment(WorkWeekPreferences.self) private var workWeek
    let isWorkWeek: Bool

    var body: some View {
        CalendarTimelineContainer(
            unit: .week(workdays: isWorkWeek ? workWeek.workdays : nil),
            initialDate: navigation.selectedDate,
            calendar: navigation.calendar,
            pageStep: .week,
            zoomScope: isWorkWeek ? .workWeek : .week,
            excludedCalendarIdentifiers: isWorkWeek ? workWeek.excludedCalendarIdentifiers : []
        )
    }
}
