import Planner
import SwiftUI
import WidgetKit

struct InboxRow: View {
    let item: WidgetInboxItem
    let date: Date

    var body: some View {
        switch item {
        case .medication(let dose):
            InboxLinkRow(
                symbol: "pills.fill",
                color: .teal,
                title: dose.medication.name,
                detail: doseDetail(dose),
                destination: CalendarDeepLink.url(forDay: dose.date)
            )
        case .reminder(let reminder):
            WidgetReminderRow(reminder: reminder)
        case .conflict(let first, let second):
            InboxLinkRow(
                symbol: "exclamationmark.triangle.fill",
                color: .orange,
                title: "\(first.title) / \(second.title)",
                detail: String(
                    format: String(localized: "Inbox.Overlap %@", table: "Widgets"), when(second.startDate)
                ),
                destination: CalendarDeepLink.url(for: second)
            )
        case .invitation(let event):
            InboxLinkRow(
                symbol: "calendar.badge.exclamationmark",
                color: event.color.color,
                title: event.title,
                detail: String(
                    format: String(localized: "Inbox.Respond %@", table: "Widgets"), when(event.startDate)
                ),
                destination: CalendarDeepLink.url(for: event)
            )
        }
    }

    private func doseDetail(_ dose: MedicationDose) -> String {
        let due = String(
            format: String(localized: "Inbox.DoseDue %@", table: "Widgets"), WidgetEventTimeText.time(dose.date)
        )
        return [due, dose.amount?.text].compactMap(\.self).joined(separator: " · ")
    }

    private func when(_ start: Date) -> String {
        let time = WidgetEventTimeText.time(start)
        guard !Calendar.current.isDate(start, inSameDayAs: date) else { return time }
        return "\(start.formatted(.dateTime.weekday(.abbreviated))) \(time)"
    }
}

struct InboxLinkRow: View {
    let symbol: String
    let color: Color
    let title: String
    let detail: String
    let destination: URL

    var body: some View {
        Link(destination: destination) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.subheadline)
                    .foregroundStyle(color)
                    .frame(width: 20)
                    .widgetAccentable()
                VStack(alignment: .leading, spacing: 0) {
                    Text(verbatim: title)
                        .font(.caption)
                    Text(verbatim: detail)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .lineLimit(1)
                Spacer(minLength: 0)
            }
        }
    }
}
