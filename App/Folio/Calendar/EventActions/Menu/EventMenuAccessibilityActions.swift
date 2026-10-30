import Planner
import SwiftUI

/// The quick actions as a flat list, for VoiceOver's actions rotor.
struct EventMenuAccessibilityActions: View {
    let event: CalendarEvent
    let actions: EventActions
    /// Month cells combine several events into one element, so their actions name the event.
    var namesEvent = false

    var body: some View {
        ForEach(actions.sections(for: event).flatMap(\.self), id: \.self) { item in
            switch item {
            case .moveToCalendar(let calendars):
                ForEach(calendars) { calendar in
                    Button(name(String(localized: "Accessibility.MoveTo \(calendar.title)", table: "EventActions"))) {
                        actions.move(event, to: calendar)
                    }
                }
            default:
                Button(name(item.title)) {
                    actions.perform(item, on: event)
                }
            }
        }
    }

    private func name(_ title: String) -> String {
        guard namesEvent else { return title }
        return String(localized: "Accessibility.EventAction \(title) \(event.title)", table: "EventActions")
    }
}
