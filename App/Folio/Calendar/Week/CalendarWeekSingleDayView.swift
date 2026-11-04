import Planner
import SwiftUI

struct CalendarWeekSingleDayView: View {
    @Environment(CalendarNavigation.self) private var navigation
    @Environment(WorkWeekPreferences.self) private var workWeek
    let isWorkWeek: Bool

    private var workdays: Set<Int>? {
        isWorkWeek ? workWeek.workdays : nil
    }

    var body: some View {
        CalendarTimelineContainer(
            unit: workdays.map(TimelineStrip.Unit.workday) ?? .day,
            columnsOnScreen: 1,
            initialDate: navigation.selectedDate,
            calendar: navigation.calendar,
            pageStep: .day,
            zoomScope: isWorkWeek ? .workWeekSingleDay : .weekSingleDay,
            excludedCalendarIdentifiers: isWorkWeek ? workWeek.excludedCalendarIdentifiers : [],
            showsDayLabels: false
        ) {
            CalendarWeekDayRow(workdays: workdays)
            CalendarDayLinkedNoteSlot(date: navigation.selectedDate, showsDivider: false)
        }
        .onChange(of: navigation.selectedDate, initial: true) { moveOntoShownDay() }
        .onChange(of: workdays) { moveOntoShownDay() }
    }

    private func moveOntoShownDay() {
        let closest = navigation.calendar.closestShownDate(to: navigation.selectedDate, workdays: workdays)
        if closest != navigation.selectedDate {
            navigation.show(closest)
        }
    }
}
