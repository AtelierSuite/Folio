import Planner
import SwiftUI

struct NoteEventPickerList: View {
    let events: [CalendarEvent]?
    let linkedKey: String?
    let onSelect: (CalendarEvent) -> Void

    var body: some View {
        if let events {
            if events.isEmpty {
                Text(String(localized: "LinkEvent.NoEvents", table: "LinkedNotes"))
                    .foregroundStyle(.secondary)
            }
            ForEach(events) { event in
                Button {
                    onSelect(event)
                } label: {
                    NoteEventPickerRow(event: event, isLinked: event.reference.storageKey == linkedKey)
                }
                .buttonStyle(.plain)
            }
        } else {
            ProgressView()
                .frame(maxWidth: .infinity)
        }
    }
}

struct NoteEventPickerRow: View {
    let event: CalendarEvent
    let isLinked: Bool

    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2)
                .fill(event.color.color)
                .frame(width: 4, height: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .lineLimit(1)
                Text(timeText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if isLinked {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
            }
        }
        .contentShape(.rect)
    }

    private var timeText: String {
        if event.isAllDay {
            return String(localized: "LinkEvent.AllDay", table: "LinkedNotes")
        }
        return (event.startDate..<max(event.startDate, event.endDate)).formatted(date: .omitted, time: .shortened)
    }
}
