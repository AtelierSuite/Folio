import Planner
import SwiftUI

struct NotificationStyleSection: View {
    @Environment(NotificationScheduler.self) private var scheduler
    @Binding var style: NotificationAlertStyle?
    let calendarIdentifier: String

    var body: some View {
        if scheduler.isEnabled {
            Section {
                NotificationStylePicker(
                    selection: style,
                    inheritedStyle: scheduler.defaultStyle(forCalendar: calendarIdentifier)
                ) { newValue in
                    style = newValue
                } label: {
                    Text(String(localized: "Row.Title", table: "NotificationStyles"))
                }
                .accessibilityIdentifier("NotificationStyleOverride")
            }
        }
    }
}
