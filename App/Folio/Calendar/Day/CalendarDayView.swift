import Planner
import SwiftUI

struct CalendarDayView: View {
    @Environment(CalendarNavigation.self) private var navigation

    var body: some View {
        CalendarTimelineContainer(
            unit: .day,
            columnsOnScreen: 1,
            initialDate: navigation.selectedDate,
            calendar: navigation.calendar,
            pageStep: .day,
            zoomScope: .day
        ) {
            CalendarDayLinkedNoteSlot(date: navigation.selectedDate)
        }
    }
}
