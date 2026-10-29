import Planner
import SwiftUI

struct EventDetailInfoSection: View {
    let event: CalendarEvent
    let draft: EventDraft?
    let calendar: PlannerCalendar?

    var body: some View {
        Section {
            LabeledContent(String(localized: "Field.Calendar", table: "EventEditor")) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(event.color.color)
                        .frame(width: 10, height: 10)
                    Text(calendar?.title ?? "")
                }
            }
            ForEach(draft?.alerts ?? []) { alert in
                LabeledContent(
                    String(localized: "Field.Alert", table: "EventEditor"),
                    value: alert.title(isAllDay: event.isAllDay)
                )
            }
            if let url = event.url {
                Link(destination: url) {
                    Label(url.absoluteString, systemImage: "link")
                        .lineLimit(1)
                }
            }
            if let notes = event.notes, !notes.isEmpty {
                Text(notes)
                    .textSelection(.enabled)
            }
        }
    }
}
