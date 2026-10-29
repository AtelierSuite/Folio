import Planner
import SwiftUI

struct NotificationStyleCalendarRow: View {
    @Environment(NotificationScheduler.self) private var scheduler
    let calendar: PlannerCalendar
    @State private var style: NotificationAlertStyle = .standard

    var body: some View {
        NotificationStylePicker(selection: style, inheritedStyle: nil) { newValue in
            guard let newValue else { return }
            style = newValue
            await scheduler.setDefaultStyle(newValue, forCalendar: calendar.id)
        } label: {
            HStack(spacing: 10) {
                Circle()
                    .fill(calendar.color.color)
                    .frame(width: 12, height: 12)
                Text(calendar.title)
            }
        }
        .accessibilityIdentifier("NotificationStyle.\(calendar.title)")
        .onAppear {
            style = scheduler.defaultStyle(forCalendar: calendar.id)
        }
    }
}
