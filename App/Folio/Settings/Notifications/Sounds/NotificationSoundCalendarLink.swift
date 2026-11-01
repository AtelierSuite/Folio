import Planner
import SwiftUI

struct NotificationSoundCalendarLink: View {
    @Environment(NotificationScheduler.self) private var scheduler
    let kind: CalendarItemKind
    let calendar: PlannerCalendar

    var body: some View {
        NavigationLink {
            NotificationSoundPickerView(kind: kind, calendar: calendar)
        } label: {
            LabeledContent {
                Text(currentTitle)
            } label: {
                HStack(spacing: 10) {
                    Circle()
                        .fill(calendar.color.color)
                        .frame(width: 12, height: 12)
                    Text(calendar.title)
                }
            }
        }
        .accessibilityIdentifier("NotificationSoundCalendar.\(calendar.title)")
    }

    private var currentTitle: String {
        if let sound = scheduler.sound(forCalendar: calendar.id) {
            sound.title
        } else {
            NotificationSound.inheritedTitle(scheduler.sound(for: kind))
        }
    }
}
