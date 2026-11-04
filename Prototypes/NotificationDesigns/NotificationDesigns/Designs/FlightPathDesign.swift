import SwiftUI

struct FlightPathDesign: View {
    let alert: SampleAlert

    var body: some View {
        VStack(spacing: 10) {
            CalendarSourceLabel(alert: alert)
            AlertTitle(alert: alert)
                .multilineTextAlignment(.center)
            if let timeSpan = alert.timeSpan {
                path(for: timeSpan)
            } else {
                Text(alert.timeSummary)
                    .font(.title3.weight(.semibold))
            }
            if let status = alert.status {
                Text(status)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(alert.color)
            }
            AlertPlaceLabels(alert: alert)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(18)
    }

    private func path(for timeSpan: SampleAlert.TimeSpan) -> some View {
        HStack(spacing: 10) {
            endpoint(timeSpan.start)
            VStack(spacing: 3) {
                Text(timeSpan.duration)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Capsule()
                    .fill(alert.color)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
            endpoint(timeSpan.end)
        }
    }

    private func endpoint(_ text: String) -> some View {
        Text(text.replacingOccurrences(of: ", ", with: "\n"))
            .font(.headline.monospacedDigit())
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: 104)
    }
}
