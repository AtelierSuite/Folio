import SwiftUI

struct AgendaColumnsDesign: View {
    let alert: SampleAlert

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            timeColumn
                .frame(width: 92, alignment: .trailing)
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                CalendarSourceLabel(alert: alert)
                AlertTitle(alert: alert)
                if let status = alert.status {
                    Text(status)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(alert.color)
                }
                AlertPlaceLabels(alert: alert)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(16)
    }

    @ViewBuilder private var timeColumn: some View {
        VStack(alignment: .trailing, spacing: 3) {
            if let timeSpan = alert.timeSpan {
                Text(timeSpan.start)
                    .font(.subheadline.weight(.semibold))
                Text(timeSpan.end)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(timeSpan.duration)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 3)
            } else {
                Text(alert.timeSummary)
                    .font(.subheadline.weight(.semibold))
            }
        }
        .multilineTextAlignment(.trailing)
    }
}
