import Planner
import SwiftUI

/// The menu items for `.contextMenu` and `Menu`. The menu a tap opens is built from the same
/// sections in `EventPlatformMenu`.
struct EventMenuContent: View {
    let event: CalendarEvent
    let actions: EventActions

    var body: some View {
        ForEach(Array(actions.sections(for: event).enumerated()), id: \.offset) { _, section in
            Section {
                ForEach(section, id: \.self) { item in
                    EventMenuItemView(item: item, event: event, actions: actions)
                }
            }
        }
    }
}

private struct EventMenuItemView: View {
    let item: EventMenuItem
    let event: CalendarEvent
    let actions: EventActions

    var body: some View {
        switch item {
        case .joinMeeting(let link):
            JoinMeetingButton(link: link, style: .menu)
        case .moveToCalendar(let calendars):
            Menu {
                ForEach(calendars) { calendar in
                    Button {
                        actions.move(event, to: calendar)
                    } label: {
                        Label(calendar.title, systemImage: "circle.fill")
                    }
                    .tint(calendar.color.color)
                }
            } label: {
                Label(item.title, systemImage: item.systemImage)
            }
            .accessibilityIdentifier(item.accessibilityIdentifier)
        default:
            Button(role: item.isDestructive ? .destructive : nil) {
                actions.perform(item, on: event)
            } label: {
                Label(item.title, systemImage: item.systemImage)
            }
            .accessibilityIdentifier(item.accessibilityIdentifier)
        }
    }
}
