import SwiftUI

struct CenteredDesign: View {
    let alert: SampleAlert

    var body: some View {
        VStack(spacing: 8) {
            CalendarSourceLabel(alert: alert)
            AlertTitle(alert: alert)
            if let status = alert.status {
                Text(status)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(alert.color)
            }
            Text(alert.timeSummary)
                .font(.subheadline)
            AlertPlaceLabels(alert: alert)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(20)
    }
}
