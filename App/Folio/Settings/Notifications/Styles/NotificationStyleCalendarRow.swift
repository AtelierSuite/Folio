import Planner
import SwiftUI

struct NotificationStyleCalendarRow: View {
    @Environment(NotificationScheduler.self) private var scheduler
    let calendar: PlannerCalendar
    @State private var style = NotificationStyleSettings.initialStyle

    var body: some View {
        NotificationStylePicker(selection: style, inheritedStyle: nil) { newValue in
            guard let newValue else { return }
            style = newValue
            await scheduler.setDefaultStyle(newValue, forCalendar: calendar.id)
        } label: {
            CalendarKindLabel(calendar: calendar)
        }
        .accessibilityIdentifier("NotificationStyle.\(calendar.title)")
        .onAppear {
            style = scheduler.defaultStyle(forCalendar: calendar.id)
        }
    }
}
