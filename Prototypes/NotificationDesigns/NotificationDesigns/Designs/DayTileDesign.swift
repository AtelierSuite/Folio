import SwiftUI

struct DayTileDesign: View {
    let alert: SampleAlert

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 14) {
                dayTile
                VStack(alignment: .leading, spacing: 4) {
                    CalendarSourceLabel(alert: alert)
                    AlertTitle(alert: alert)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            VStack(spacing: 4) {
                Text(alert.timeSummary)
                    .font(.subheadline.weight(.medium))
                if let status = alert.status {
                    Text(status)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(alert.color)
                }
                AlertPlaceLabels(alert: alert)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
        }
        .padding(16)
    }

    private var dayTile: some View {
        VStack(spacing: 0) {
            Text(alert.monthName)
                .font(.caption2.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 2)
                .background(alert.color)
            Text(alert.dayNumber)
                .font(.title2.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
        }
        .frame(minWidth: 56)
        .fixedSize()
        .background(.primary.opacity(0.08))
        .clipShape(.rect(cornerRadius: 12))
    }
}
