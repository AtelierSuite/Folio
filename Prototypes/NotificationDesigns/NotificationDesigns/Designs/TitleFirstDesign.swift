import SwiftUI

struct TitleFirstDesign: View {
    let alert: SampleAlert

    var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 6) {
                AlertTitle(alert: alert)
                Text(alert.timeSummary)
                    .font(.subheadline)
                AlertPlaceLabels(alert: alert)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            Divider()
            HStack(spacing: 12) {
                CalendarSourceLabel(alert: alert)
                Spacer(minLength: 0)
                if let status = alert.status {
                    Text(status)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(alert.color)
                        .fixedSize()
                }
            }
        }
        .padding(16)
    }
}
