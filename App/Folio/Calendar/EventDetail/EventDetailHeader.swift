import Planner
import SwiftUI

struct EventDetailHeader: View {
    let event: CalendarEvent
    let recurrence: EventRecurrence?
    var calendar: Calendar = .current

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title.isEmpty ? String(localized: "Detail.Untitled", table: "EventEditor") : event.title)
                    .font(.title2.bold())
                    .textSelection(.enabled)
                ForEach(dateLines, id: \.self) { line in
                    Text(line)
                        .foregroundStyle(.secondary)
                }
                if let recurrence {
                    Label(recurrence.summary, systemImage: "repeat")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var dateLines: [String] {
        let dayStyle = Date.FormatStyle.dateTime.weekday(.wide).month(.wide).day().year()
        if event.isAllDay {
            let lastDay = calendar.date(byAdding: .second, value: -1, to: event.endDate) ?? event.startDate
            if calendar.isDate(event.startDate, inSameDayAs: lastDay) {
                return [event.startDate.formatted(dayStyle), String(localized: "Detail.AllDay", table: "EventEditor")]
            }
            return [
                String(localized: "Detail.From \(event.startDate.formatted(dayStyle))", table: "EventEditor"),
                String(localized: "Detail.To \(lastDay.formatted(dayStyle))", table: "EventEditor")
            ]
        }
        if calendar.isDate(event.startDate, inSameDayAs: event.endDate) {
            return [
                event.startDate.formatted(dayStyle),
                (event.startDate..<event.endDate).formatted(.interval.hour().minute())
            ]
        }
        let dateTimeStyle = Date.FormatStyle.dateTime.month(.abbreviated).day().year().hour().minute()
        return [
            String(localized: "Detail.From \(event.startDate.formatted(dateTimeStyle))", table: "EventEditor"),
            String(localized: "Detail.To \(event.endDate.formatted(dateTimeStyle))", table: "EventEditor")
        ]
    }
}
