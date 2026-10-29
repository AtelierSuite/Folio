import Planner
import SwiftUI

struct InvitationRow: View {
    let event: CalendarEvent

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .strokeBorder(event.color.color, style: StrokeStyle(lineWidth: 1.5, dash: [3, 2]))
                .frame(width: 6)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.body)
                Text(dateDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let organizer = event.organizer?.displayName, !organizer.isEmpty {
                    Text(String(localized: "List.From \(organizer)", table: "Invitations"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    private var dateDescription: String {
        let day = event.startDate.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
        if event.isAllDay { return day }
        return "\(day), \(event.startDate.formatted(date: .omitted, time: .shortened))"
    }
}
