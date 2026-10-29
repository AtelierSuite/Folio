import Planner
import SwiftUI

struct AgendaEventRow: View {
    let event: CalendarEvent

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(event.color.color)
                .frame(width: 4)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.body)
                if event.isAllDay {
                    Text(String(localized: "Event.AllDay", table: "Agenda"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text(event.startDate..<event.endDate, format: .interval.hour().minute())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if let location = event.location, !location.isEmpty {
                    Text(location)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
            if event.isReadOnly {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .accessibilityLabel(String(localized: "Event.ReadOnly", table: "Agenda"))
            }
        }
    }
}
