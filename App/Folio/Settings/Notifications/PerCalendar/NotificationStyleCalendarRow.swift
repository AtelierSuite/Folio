import Planner
import SwiftUI

struct NotificationStyleCalendarRow: View {
    @Environment(NotificationScheduler.self) private var scheduler
    let calendar: PlannerCalendar
    @Binding var style: NotificationAlertStyle

    var body: some View {
        NotificationStyleGallery(selection: style) { newValue in
            style = newValue
            await scheduler.setDefaultStyle(newValue, forCalendar: calendar.id)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("NotificationStyle.\(calendar.title)")
    }
}
