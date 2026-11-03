import Planner
import SwiftUI

struct NotificationStyleCalendarRow: View {
    @Environment(NotificationScheduler.self) private var scheduler
    let calendar: PlannerCalendar
    @Binding var style: NotificationAlertStyle

    var body: some View {
        NotificationStylePicker(selection: style, inheritedStyle: nil) { newValue in
            guard let newValue else { return }
            style = newValue
            await scheduler.setDefaultStyle(newValue, forCalendar: calendar.id)
        } label: {
            Text(String(localized: "Row.Title", table: "NotificationStyles"))
        }
        .accessibilityIdentifier("NotificationStyle.\(calendar.title)")
    }
}
