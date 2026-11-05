import Planner
import SwiftUI

struct NotificationDetailView: View {
    let detail: NotificationDetail

    var body: some View {
        VStack(spacing: 12) {
            if detail.origin != nil || detail.hasStatus {
                // The schedule's date is rounded down to the minute, so it only triggers the refresh.
                TimelineView(.everyMinute) { _ in
                    NotificationDetailHeaderView(
                        origin: detail.origin,
                        status: detail.status(at: .now),
                        accentColor: accentColor,
                        statusColor: detail.isOverdue(at: .now) ? .red : accentColor
                    )
                }
                Divider()
            }
            if let medication = detail.medication {
                NotificationMedicationDosesView(doses: medication.doses, accentColor: accentColor)
                NotificationDetailFooterView(leading: detail.row(.time), trailing: nil)
                Text(medication.note)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("NotificationDetail.Note")
            } else if let reminder = detail.reminder {
                NotificationReminderTaskView(title: detail.title, reminder: reminder, accentColor: accentColor)
                NotificationDetailFooterView(leading: detail.row(.time), trailing: detail.row(.repeating))
            } else {
                eventSummary
                NotificationDetailFooterView(leading: detail.row(.place), trailing: detail.row(.meeting))
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(16)
    }

    private var eventSummary: some View {
        VStack(spacing: 6) {
            Text(detail.title)
                .font(.title3.bold())
                .lineLimit(3)
                .accessibilityIdentifier("NotificationDetail.Title")
            if let time = detail.row(.time) {
                Text(time.text)
                    .font(.subheadline)
                    .accessibilityIdentifier("NotificationDetail.Time")
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }

    private var accentColor: Color {
        detail.color.map { Color(red: $0.red, green: $0.green, blue: $0.blue) } ?? .accentColor
    }
}
